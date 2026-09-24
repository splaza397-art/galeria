import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../services/favorite_service.dart';
import '../services/image_service.dart';
import '../editor/image_editor.dart';

class ImageViewer extends StatefulWidget {
  final AssetEntity image;

  const ImageViewer({
    super.key,
    required this.image,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final FavoriteService _favoriteService = FavoriteService();
  final ImageService _imageService = ImageService();

  bool _isFavorite = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();

    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final bool isFavorite =
    await _favoriteService.isFavorite(widget.image.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _isFavorite = isFavorite;
      _isLoadingFavorite = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isLoadingFavorite) {
      return;
    }

    final bool newFavoriteState = !_isFavorite;

    setState(() {
      _isFavorite = newFavoriteState;
    });

    try {
      final bool savedState =
      await _favoriteService.toggleFavorite(
        widget.image.id,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isFavorite = savedState;
      });

      if (savedState == false && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isFavorite = !newFavoriteState;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo actualizar favoritos.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildImage(),
          _buildTopButtons(),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Center(
      child: FutureBuilder<Uint8List?>(
        future: widget.image.originBytes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(
              color: Colors.white,
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Icon(
              Icons.broken_image_outlined,
              color: Colors.white,
              size: 80,
            );
          }

          return InteractiveViewer(
            minScale: 1.0,
            maxScale: 5.0,
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.contain,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopButtons() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            right: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: _isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                iconColor: _isFavorite
                    ? Colors.red
                    : Colors.white,
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline,
                onPressed: _deleteImage,
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit_outlined,
                onPressed: _openEditor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openEditor() async {
    final bool? imageWasSaved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          image: widget.image,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (imageWasSaved == true) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildBackButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 8,
            left: 8,
          ),
          child: _buildActionButton(
            icon: Icons.arrow_back,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color iconColor = Colors.white,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.black.withValues(
        alpha: 0.55,
      ),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteImage() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminar fotografía'),
          content: const Text(
            '¿Quieres eliminar esta fotografía del teléfono?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete != true) {
      return;
    }

    try {
      final bool deleted =
      await _imageService.deleteImage(widget.image);

      if (!mounted) {
        return;
      }

      if (deleted) {
        await _favoriteService.removeFavorite(
          widget.image.id,
        );

        if (!mounted) {
          return;
        }

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo eliminar la fotografía.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un error al eliminar la fotografía.',
          ),
        ),
      );
    }
  }
}