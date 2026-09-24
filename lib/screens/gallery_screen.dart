import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/image_service.dart';
import '../widgets/image_grid.dart';
import 'favorites_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImageService _imageService = ImageService();

  List<AssetEntity> _images = [];

  bool _isLoading = true;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final PermissionState permission =
      await _imageService.requestPermission();

      if (!permission.hasAccess) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isLoading = false;
          _errorMessage =
          'No tenemos permiso para acceder a las fotografías.';
        });

        return;
      }

      final List<AssetEntity> images =
      await _imageService.getImages();

      if (!mounted) {
        return;
      }

      setState(() {
        _images = images;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
        'Ocurrió un error al cargar las fotografías.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Galería'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
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

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadImages,
                child: const Text('Intentar nuevamente'),
              ),
            ],
          ),
        ),
      );
    }

    return ImageGrid(
      images: _images,
      onImageChanged: _loadImages,
    );
  }
}