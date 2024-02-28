import 'dart:convert';

import 'package:articles_app/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'article_card.dart';

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<dynamic> articleInfo = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchArticles(); // Call fetchArticles() in initState()
  }

  void fetchArticles() async {
    const String url = "https://hn.algolia.com/api/v1/search?tags=front_page";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    setState(() {
      articleInfo = json["hits"];
    });
  }

  Future<bool> _getFavoriteState(int index) async {
    final favorites = await SharedPreferences.getInstance();
    final isFavorite = favorites.getBool('$index');
    if (isFavorite == null) {
      return false;
    }
    return isFavorite;
  }

  Future<bool> _changeFavoriteState(int index) async {
    final favorites = await SharedPreferences.getInstance();
    final isFavorite = favorites.getBool('$index');
    if (isFavorite == null) {
      await favorites.setBool('$index', true);
      return true;
    }
    await favorites.setBool('$index', !isFavorite);
    return false;
  }

  Future<List<Article>> _initializeArticles(List<dynamic> articleToInit) async {
    List<Article> articleList = [];
    for (int index = 0; index < articleToInit.length; index++) {
      final article = Article(
        title: articleToInit[index]["title"] ?? "Title not available",
        author: articleToInit[index]["author"] ?? "Author not available",
        commentCount: articleToInit[index]["num_comments"] ?? 0,
        pointCount: articleToInit[index]["points"] ?? 0,
        url: articleToInit[index]["url"] ?? "",
        isFavorited: await _getFavoriteState(index),
      );
      articleList.add(article);
    }
    return articleList;
  }

   Future<List<Article>> _searchArticles(String keyword) async {
    if (keyword.isEmpty) {
      return await _initializeArticles(articleInfo);
    }
    return _initializeArticles(articleInfo
        .where((article) => article["title"].toLowerCase().contains(keyword.toLowerCase()))
        .toList());
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
                  onPressed: () {},
                  icon: const Icon(
                    Icons.filter_list,
                    size: 38,
                  )),
            )
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
                  onChanged: (value){ _searchArticles(value); setState(() {});},),
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
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const FavoritesPage())),
          ),
        ),
        body: FutureBuilder<List<Article>>(
          future: _searchArticles(_searchController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return  Center(child: Text(
                  'Error: ${snapshot.error}')); 
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
                      _changeFavoriteState(index);
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

// ListView.builder(
//         itemCount: articleInfo.length,
//         itemBuilder: (context, index) {

//           final article = Article(
//             title: articleInfo[index]["title"] ?? "Title not available",
//             author: articleInfo[index]["author"] ?? "Author not available",
//             commentCount: articleInfo[index]["num_comments"] ?? 0,
//             pointCount: articleInfo[index]["points"] ?? 0,
//             url: articleInfo[index]["url"] ?? "",
//             isFavorited:  false,
//           );

//           return ArticleCard(
//             title: article.title,
//             author: article.author,
//             commentCount: article.commentCount,
//             pointCount: article.pointCount,
//             url: article.url,
//             isFavorited: article.isFavorited,
//             onFavoritePressed: () {
//               _changeFavoriteState(index);
//             },
//           );
//         },
//       ),
