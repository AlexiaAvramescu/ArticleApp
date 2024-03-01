import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'article_card.dart';
import 'utils.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.articleInfo});
  final List<dynamic> articleInfo;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> get articleInfo => widget.articleInfo;
  Future<List<Article>> getFavorites() async {
    final favorites = await SharedPreferences.getInstance();
    return initializeArticles(articleInfo
        .where((article) =>
            favorites.getBool(article['objectID'] ?? false) == true)
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text('Favorites'),
        ),
        body: FutureBuilder<List<Article>>(
          future: getFavorites(),
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
