import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageEditor extends StatefulWidget {
  final AssetEntity image;

  const ImageEditor({
    super.key,
    required this.image,
  });

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  File? _imageFile;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final File? file = await widget.image.file;

      if (!mounted) {
        return;
      }

      setState(() {
        _imageFile = file;
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

  Future<void> _cropImage() async {
    if (_imageFile == null || _isSaving) {
      return;
    }

    try {
      final CroppedFile? croppedFile =
      await ImageCropper().cropImage(
        sourcePath: _imageFile!.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar fotografía',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _imageFile = File(croppedFile.path);
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo recortar la fotografía.',
          ),
        ),
      );
    }
  }

  Future<void> _saveImage() async {
    if (_imageFile == null || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final Uint8List imageBytes =
      await _imageFile!.readAsBytes();

      final AssetEntity savedImage =
      await PhotoManager.editor.saveImage(
        imageBytes,
        title: 'foto_editada',
        filename: 'foto_editada.jpg',
      );

      if (!mounted) {
        return;
      }

      if (savedImage.id.isNotEmpty) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar la fotografía.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ocurrió un error al guardar la fotografía.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar fotografía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop),
            onPressed: _isSaving
                ? null
                : _cropImage,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving
                ? null
                : _saveImage,
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

    if (_imageFile == null) {
      return const Center(
        child: Text(
          'No se pudo cargar la fotografía.',
        ),
      );
    }

    return Stack(
      children: [
        Center(
          child: Image.file(
            _imageFile!,
            fit: BoxFit.contain,
          ),
        ),
        if (_isSaving)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Guardando...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}