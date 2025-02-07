import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:ts/models/photo.dart';

class DriveService {
  static const _scopes = [drive.DriveApi.driveReadonlyScope];
  late drive.DriveApi _driveApi;
  
  Future<void> initialize(String apiKey) async {
    final client = await clientViaApiKey(apiKey);
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
        pageSize: pageSize,
        pageToken: pageToken,
        orderBy: 'createdTime desc',
        fields: 'files(id, name, createdTime, webContentLink)',
      );

      return response.files?.map((file) => Photo(
        id: file.id!,
        name: file.name!,
        url: file.webContentLink!,
        createdTime: file.createdTime!,
      )).toList() ?? [];
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }
}