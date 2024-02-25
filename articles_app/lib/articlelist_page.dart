import 'package:flutter/material.dart';


class Article {
  final String title;
  final String author;
  final int commentCount;
  final int pointCount;
  bool isFavorited;

  Article({
    required this.title,
    required this.author,
    required this.commentCount,
    required this.pointCount,
    required this.isFavorited,
  });
}


class ArticleCard extends StatelessWidget {
  final String title;
  final String author;
  final int commentCount;
  final int pointCount;
  final bool isFavorited;
  final VoidCallback onFavoritePressed;

  ArticleCard({
    required this.title,
    required this.author,
    required this.commentCount,
    required this.pointCount,
    required this.isFavorited,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By $author'),
            InkWell(
              child: Text(
                'Read here',
                style: TextStyle(color: Colors.blue),
              ),
              onTap: () {
                // Handle the link tap
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
  @override
  Widget build(BuildContext context) {
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
        itemCount: 10, // Change this to the number of articles
        itemBuilder: (context, index) {
          // Mock article data for testing
          final article = Article(
            title: 'Article $index',
            author: 'Author $index',
            commentCount: index * 5,
            pointCount: index * 10,
            isFavorited: false,
          );

          return ArticleCard(
            title: article.title,
            author: article.author,
            commentCount: article.commentCount,
            pointCount: article.pointCount,
            isFavorited: article.isFavorited,
            onFavoritePressed: () {
              // Implement your logic to handle favorite button press
            },
          );
        },
      ),
    );
  }
}