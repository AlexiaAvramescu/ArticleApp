
import 'package:flutter/material.dart';
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
  final Function(bool value) onFavoritePressed;

  const ArticleCard({super.key, 
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
          ],
        ),
        onTap: () async{
          if (!await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                )) {
                  throw Exception('Could not launch $url');
                }
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red[300] : null,
              ),
              onPressed: onFavoritePressed(isFavorited),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$commentCount Comments'),
                Text('$pointCount Points'),
              ],
            ),
          ]
      ),
    ));
  }
}