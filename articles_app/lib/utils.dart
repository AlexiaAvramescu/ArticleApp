import 'package:shared_preferences/shared_preferences.dart';
import 'article_card.dart';

Future<bool> getFavoriteState(String id) async {
  final favorites = await SharedPreferences.getInstance();
  final isFavorite = favorites.getBool(id);
  if (isFavorite == null) {
    return false;
  }
  return isFavorite;
}

Future<bool> changeFavoriteState(String id) async {
  final favorites = await SharedPreferences.getInstance();
  final isFavorite = favorites.getBool(id);
  if (isFavorite == null) {
    await favorites.setBool(id, true);
    return true;
  }
  await favorites.setBool(id, !isFavorite);
  return false;
}

Future<List<Article>> initializeArticles(List<dynamic> articleToInit) async {
  List<Article> articleList = [];
  for (int index = 0; index < articleToInit.length; index++) {
    if (articleToInit[index]["objectID"] == '') continue;
    final article = Article(
      id: articleToInit[index]["objectID"],
      title: articleToInit[index]["title"] ?? "Title not available",
      author: articleToInit[index]["author"] ?? "Author not available",
      date: DateTime.parse(articleToInit[index]["created_at"]),
      commentCount: articleToInit[index]["num_comments"] ?? 0,
      pointCount: articleToInit[index]["points"] ?? 0,
      url: articleToInit[index]["url"] ?? "",
      isFavorited: await getFavoriteState(articleToInit[index]["objectID"]),
    );
    articleList.add(article);
  }
  return articleList;
}


