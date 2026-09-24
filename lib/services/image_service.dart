import 'package:photo_manager/photo_manager.dart';
class ImageService {
  Future<PermissionState> requestPermission() async {
    final PermissionState permission =
    await PhotoManager.requestPermissionExtend();
    return permission;
  }
  Future<List<AssetEntity>> getImages() async {
    final PermissionState permission =
    await PhotoManager.requestPermissionExtend();
    if (!permission.hasAccess) {
      return [];
    }
    final List<AssetPathEntity> albums =
    await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );
    if (albums.isEmpty) {
      return [];
    }
    final AssetPathEntity allImages = albums.first;
    final List<AssetEntity> allImagesList = [];
    int page = 0;
    const int pageSize = 100;
    while (true) {
      final List<AssetEntity> batch =
      await allImages.getAssetListPaged(
        page: page,
        size: pageSize,
      );
      allImagesList.addAll(batch);
      if (batch.length < pageSize) {
        break;
      }
      page++;
    }
    // Ordenar de la fotografía más nueva a la más antigua.
    allImagesList.sort(
          (a, b) => b.createDateTime.compareTo(
        a.createDateTime,
      ),
    );

    return allImagesList;
  }
  Future<bool> deleteImage(AssetEntity image) async {
    final List<String> deletedIds =
    await PhotoManager.editor.deleteWithIds(
      [image.id],
    );
    return deletedIds.contains(image.id);
  }
}