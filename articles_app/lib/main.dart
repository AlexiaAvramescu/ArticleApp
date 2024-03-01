import 'package:flutter/material.dart';
import 'package:articles_app/articlelist_page.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainPage(),
  ));
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
        width: 200,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ArticleListPage(),
              ),
            );
          },
          child: const Text(
            'Article List',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      )),
    );
  }
}
