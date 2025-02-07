import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

class PhotoService {
  Future<String> downloadPhoto(String url, String fileName) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Failed to download photo');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final localPath = path.join(appDir.path, 'photos', fileName);

    final photoDir = Directory(path.dirname(localPath));
    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    final file = File(localPath);
    await file.writeAsBytes(response.bodyBytes);
    return localPath;
  }

  Future<void> sharePhoto(String photoPath, String? caption) async {
    final file = XFile(photoPath);
    await Share.shareXFiles(
      [file],
      text: caption,
    );
  }

  Future<bool> isPhotoDownloaded(String localPath) async {
    if (localPath.isEmpty) return false;
    final file = File(localPath);
    return file.exists();
  }

  Future<void> deleteLocalPhoto(String localPath) async {
    if (localPath.isEmpty) return;
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
