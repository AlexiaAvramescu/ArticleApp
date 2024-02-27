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

  const ArticleCard(
      {super.key,
      required this.title,
      required this.author,
      required this.commentCount,
      required this.pointCount,
      required this.url,
      required this.isFavorited,
      required this.onFavoritePressed});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        margin: const EdgeInsets.all(8),
        child: ListTile(
          leading: IconButton(
            icon: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              color: isFavorited ? Colors.red[300] : null,
            ),
            onPressed: onFavoritePressed,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('By $author'),
            ],
          ),
          onTap: () async {
            if(url.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No link available for this article.'),
                  duration:
                      Duration(seconds: 2), // Adjust the duration as needed
                ),
              );
              return;
            }
            if (!await launchUrl(
              Uri.parse(url),
              mode: LaunchMode.externalApplication,
            )) {
              throw Exception('Could not launch $url');
            }
          },
          trailing: Column(mainAxisSize: MainAxisSize.min, children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$commentCount Comments'),
                Text('$pointCount Points'),
              ],
            ),
          ]),
        ));
  }
}

class ArticleListPage extends StatefulWidget {
  const ArticleListPage({super.key});

  @override
  State<ArticleListPage> createState() => _ArticleListPageState();
}

class _ArticleListPageState extends State<ArticleListPage> {
  List<dynamic> articles = [];

  void fetchArticles() async {
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
          onPressed: () {
            
          },
        ),
      ),
      body: ListView.builder(
        itemCount: articles.length, // Change this to the number of articles
        itemBuilder: (context, index) {
          // Mock article data for testing
          final article = Article(
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
              // TO DO
            },
          );
        },
      ),
    );
  }
}
