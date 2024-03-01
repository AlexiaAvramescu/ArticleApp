import 'package:articles_app/articlelist_page.dart';
import 'package:flutter/material.dart';

import 'package:articles_app/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'article_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> articles = [];

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
                icon: const Icon(
                  Icons.filter_list,
                  size: 38,),
                onPressed: () {},
                ),
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
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
              onChanged: (value) {},
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
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=> const FavoritesPage())),
        ),
      ),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (context, index) {

          final article = Article(
            id: articles[index]["objectID"],
            title: articles[index]["title"] ?? "Title not available",
            author: articles[index]["author"] ?? "Author not available",
            commentCount: articles[index]["num_comments"] ?? 0,
            pointCount: articles[index]["points"] ?? 0,
            url: articles[index]["url"] ?? "",
            isFavorited: false,
          );

          return ArticleCard(
            title: article.title,
            author: article.author,
            commentCount: article.commentCount,
            pointCount: article.pointCount,
            url: article.url,
            isFavorited: article.isFavorited,
            onFavoritePressed: () {
              ;
            },
          );
        },
      ),
    );
  }
}