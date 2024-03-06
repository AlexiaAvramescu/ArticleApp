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
  final TextEditingController _minPointsController =
      TextEditingController(text: '0');
  final TextEditingController _maxPointsController =
      TextEditingController(text: '0');
  final TextEditingController _startDateController =
      TextEditingController(text: '');
  final TextEditingController _endDateController =
      TextEditingController(text: '');
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
    List<Article> searchedArticleList;
    if (keyword.isEmpty) {
      searchedArticleList = await initializeArticles(articleInfo);
    } else {
      searchedArticleList = await initializeArticles(articleInfo
          .where((article) =>
              article["title"].toLowerCase().contains(keyword.toLowerCase()))
          .toList());
    }

    return searchedArticleList;
  }

  List<Article> _sortArticle(List<Article> articles) {
    articles.sort((elem1, elem2) =>
        elem1.compare(_typeSortOption, _orderSortOption, elem2));

    return articles;
  }

  List<Article> _filterDateArticle(List<Article> articleList) {
    DateTime? startDate = DateTime.tryParse(_startDateController.text);
    DateTime? endDate = DateTime.tryParse(_endDateController.text);

    if (startDate == null && endDate == null) return articleList;

    if (startDate != null && endDate != null) {
      if (startDate.isAfter(endDate)) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Date Range'),
              content: const Text('Start date cannot be later than end date.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return articleList;
      }
    }

    List<Article> filteredList = articleList.where((article) {
      if (startDate != null && endDate != null) {
        return article.date.isAfter(startDate) &&
            article.date.isBefore(endDate);
      } else if (startDate != null) {
        return article.date.isAfter(startDate);
      } else {
        return article.date.isBefore(endDate!);
      }
    }).toList();

    return filteredList;
  }

  List<Article> _filterPointsArticle(List<Article> articleList) {
    int minPoints = int.tryParse(_minPointsController.text) ?? 0;
    int maxPoints = int.tryParse(_maxPointsController.text) ?? 0;

    if (minPoints == 0 && maxPoints == 0) return articleList;

    if (minPoints > maxPoints) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Invalid Range'),
            content: const Text(
                'Minimum points cannot be greater than maximum points.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
    List<Article> filteredList = articleList.where((article) {
      return article.pointCount >= minPoints && article.pointCount <= maxPoints;
    }).toList();

    return filteredList;
  }

  Future<List<Article>> _getArticles(String keyword) async {
    List<Article> articleList = await _searchArticles(keyword);
    articleList = _sortArticle(articleList);
    articleList = _filterPointsArticle(articleList);
    articleList = _filterDateArticle(articleList);

    return articleList;
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 20),
                        child: Column(
                          children: [
                            Row(
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
                                  items: <String>['date', 'points']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
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
                                  items: <String>['ascending', 'descending']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Filter by points:'),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextField(
                                    controller: _minPointsController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _maxPointsController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Text('Filter by dates:'),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: TextFormField(
                                    controller: _startDateController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      hintText: 'Start Date (YYYY-MM-DD)',
                                    ),
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _startDateController.text = picked
                                              .toIso8601String()
                                              .substring(0, 10);
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _endDateController,
                                    keyboardType: TextInputType.datetime,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                      hintText: 'Start Date (YYYY-MM-DD)',
                                    ),
                                    onTap: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _endDateController.text = picked
                                              .toIso8601String()
                                              .substring(0, 10);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
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
          future: _getArticles(_searchController.text),
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
