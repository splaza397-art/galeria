import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_image_ids';

  Future<Set<String>> getFavorites() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final List<String> favorites =
        preferences.getStringList(_favoritesKey) ?? [];

    return favorites.toSet();
  }

  Future<bool> isFavorite(String imageId) async {
    final Set<String> favorites = await getFavorites();

    return favorites.contains(imageId);
  }

  Future<bool> toggleFavorite(String imageId) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final List<String> favorites =
        preferences.getStringList(_favoritesKey) ?? [];

    if (favorites.contains(imageId)) {
      favorites.remove(imageId);

      await preferences.setStringList(
        _favoritesKey,
        favorites,
      );

      return false;
    }

    favorites.add(imageId);

    await preferences.setStringList(
      _favoritesKey,
      favorites,
    );

    return true;
  }

  Future<void> removeFavorite(String imageId) async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final List<String> favorites =
        preferences.getStringList(_favoritesKey) ?? [];

    favorites.remove(imageId);

    await preferences.setStringList(
      _favoritesKey,
      favorites,
    );
  }
}