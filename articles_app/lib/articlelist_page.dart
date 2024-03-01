import 'dart:convert';
import 'package:articles_app/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'article_card.dart';
import 'utils.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<dynamic> articleInfo = [];
  final TextEditingController _searchController = TextEditingController();
  String _orderSortOption = 'ascending';
  String _typeSortOption = 'date';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  void _fetchArticles() async {
    const String url = "https://hn.algolia.com/api/v1/search?tags=front_page";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    setState(() {
      articleInfo = json["hits"];
    });
  }

  Future<List<Article>> _searchArticles(String keyword) async {
    List<Article> sortedArticleList;
    if (keyword.isEmpty) {
      sortedArticleList = await initializeArticles(articleInfo);
    } else {
      sortedArticleList = await initializeArticles(articleInfo
          .where((article) =>
              article["title"].toLowerCase().contains(keyword.toLowerCase()))
          .toList());
    }

    sortedArticleList.sort((elem1, elem2) =>
        elem1.compare(_typeSortOption, _orderSortOption, elem2));
    return sortedArticleList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text('Article List'),
          actions: [
            Container(
              padding: const EdgeInsets.only(right: 20),
              child: IconButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context)
                            .size
                            .width, // Set width to full screen width
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Row(
                          children: [
                            const Text('Sort By:'),
                            const SizedBox(width: 20),
                            DropdownButton<String>(
                              value: _typeSortOption,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _typeSortOption = newValue!;
                                });
                              },
                              items: <String>[
                                'date',
                                'points'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                            const SizedBox(width: 20),
                            DropdownButton<String>(
                              value: _orderSortOption,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _orderSortOption = newValue!;
                                });
                              },
                              items: <String>[
                                'ascending',
                                'descending'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(
                  Icons.filter_list,
                  size: 38,
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue[200],
          ),
          child: IconButton(
            icon: const Icon(Icons.favorite),
            iconSize: 40,
            color: Colors.white,
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavoritesPage(
                          articleInfo: articleInfo,
                        ))),
          ),
        ),
        body: FutureBuilder<List<Article>>(
          future: _searchArticles(_searchController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  Article article = snapshot.data![index];
                  return ArticleCard(
                    title: article.title,
                    author: article.author,
                    commentCount: article.commentCount,
                    pointCount: article.pointCount,
                    url: article.url,
                    isFavorited: article.isFavorited,
                    onFavoritePressed: () {
                      changeFavoriteState(article.id);
                      setState(() {});
                    },
                  );
                },
              );
            }
          },
        ));
  }
}
