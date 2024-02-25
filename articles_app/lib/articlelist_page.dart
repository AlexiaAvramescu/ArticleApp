import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class Article {
  final String title;
  final String author;
  final int commentCount;
  final int pointCount;
  final String url;
  bool isFavorited;

  Article({
    required this.title,
    required this.author,
    required this.commentCount,
    required this.pointCount,
    required this.url,
    required this.isFavorited,
  });
}


class ArticleCard extends StatelessWidget {
  final String title;
  final String author;
  final int commentCount;
  final int pointCount;
  final bool isFavorited;
  final String url;
  final VoidCallback onFavoritePressed;

  ArticleCard({
    required this.title,
    required this.author,
    required this.commentCount,
    required this.pointCount,
    required this.url,
    required this.isFavorited,
    required this.onFavoritePressed
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By $author'),
            InkWell(
              child: const Text(
                'Read here',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () async{
                // to do 
              },
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red[300] : null,
              ),
              onPressed: onFavoritePressed,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$commentCount Comments'),
                Text('$pointCount Points'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
    List<dynamic> articles = [];

    void fetchArticles() async{
      const String url = "https://hn.algolia.com/api/v1/search?tags=front_page";
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final body = response.body;
      final json = jsonDecode(body);
      setState(() {
        articles = json["hits"];
      });
  }
  
  @override
  Widget build(BuildContext context) {
    fetchArticles();
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('Article List'),
        actions: [Container(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            onPressed: (){} ,
            icon: const Icon(Icons.favorite, size: 38,)),
        )],
      ),
      body: ListView.builder(
        itemCount: articles.length, // Change this to the number of articles
        itemBuilder: (context, index) {
          // Mock article data for testing
          final article = Article(
            title: articles[index]["title"],
            author: articles[index]["author"],
            commentCount: articles[index]["num_comments"],
            pointCount: articles[index]["points"],
            url: articles[index]["url"],
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
              // TO DO
            },
          );
        },
      ),
    );
  }
}