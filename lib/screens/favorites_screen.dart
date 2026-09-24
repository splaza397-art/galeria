import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/favorite_service.dart';
import '../services/image_service.dart';
import '../widgets/image_grid.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  final ImageService _imageService = ImageService();

  List<AssetEntity> _favoriteImages = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Set<String> favoriteIds =
      await _favoriteService.getFavorites();

      final List<AssetEntity> allImages =
      await _imageService.getImages();

      final List<AssetEntity> favoriteImages =
      allImages.where((image) {
        return favoriteIds.contains(image.id);
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _favoriteImages = favoriteImages;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_favoriteImages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 70,
            ),
            SizedBox(height: 16),
            Text(
              'No tienes fotografías favoritas.',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return ImageGrid(
      images: _favoriteImages,
      onImageChanged: _loadFavorites,
    );
  }
}