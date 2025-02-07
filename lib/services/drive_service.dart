import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:ts/models/photo.dart';

class DriveService {
  late drive.DriveApi _driveApi;

  Future<void> initialize(String apiKey) async {
    final client = clientViaApiKey(apiKey);
    _driveApi = drive.DriveApi(client);
  }

  Future<List<Photo>> fetchPhotos({
    required String folderId,
    String? pageToken,
    int pageSize = 20,
  }) async {
    try {
      final response = await _driveApi.files.list(
        q: "'$folderId' in parents and mimeType contains 'image/'",
        $fields:
            'files(id, name, createdTime, webContentLink, size, mimeType, description)',
        pageSize: pageSize,
        pageToken: pageToken,
        orderBy: 'createdTime desc',
      );

      return response.files
              ?.map((file) => Photo(
                    id: file.id!,
                    name: file.name!,
                    url: file.webContentLink!,
                    createdTime: file.createdTime!,
                    size: int.tryParse(file.size ?? ''),
                    mimeType: file.mimeType,
                    description: file.description,
                  ))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }

  Future<List<Photo>> fetchPhotosAfter(DateTime? lastSync) async {
    try {
      final query = lastSync != null
          ? "mimeType contains 'image/' and createdTime > '${lastSync.toIso8601String()}'"
          : "mimeType contains 'image/'";

      final response = await _driveApi.files.list(
        q: query,
        $fields:
            'files(id, name, createdTime, webContentLink, size, mimeType, description)',
        orderBy: 'createdTime desc',
      );

      return response.files
              ?.map((file) => Photo(
                    id: file.id!,
                    name: file.name!,
                    url: file.webContentLink!,
                    createdTime: file.createdTime!,
                    size: int.tryParse(file.size ?? ''),
                    mimeType: file.mimeType,
                    description: file.description,
                  ))
              .toList() ??
          [];
    } catch (e) {
      throw Exception('Failed to fetch new photos: $e');
    }
  }
}
