import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'image_viewer.dart';
class ImageGrid extends StatelessWidget {
  final List<AssetEntity> images;
  final VoidCallback? onImageChanged;
  const ImageGrid({
    super.key,
    required this.images,
    this.onImageChanged,
  });
  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const Center(
        child: Text(
          'No hay fotografías disponibles.',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final AssetEntity image = images[index];

        return GestureDetector(
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewer(
                  image: image,
                ),
              ),
            );

            if (result == true) {
              onImageChanged?.call();
            }
          },
          child: _ImageThumbnail(
            image: image,
          ),
        );
      },
    );
  }
}
class _ImageThumbnail extends StatelessWidget {
  final AssetEntity image;
  const _ImageThumbnail({
    required this.image,
  });
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: image.thumbnailDataWithSize(
        const ThumbnailSize(300, 300),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 40,
              ),
            ),
          );
        }
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }
}