import 'package:intl/intl.dart';

class Photo {
  final String id;
  final String name;
  final String url;
  final DateTime createdTime;
  final String? description;
  final int? size;
  final String? mimeType;
  bool isFavorite;

  Photo({
    required this.id,
    required this.name,
    required this.url,
    required this.createdTime,
    this.description,
    this.size,
    this.mimeType,
    this.isFavorite = false,
  });

  String get formattedDate => DateFormat.yMMMd().format(createdTime);
  String get formattedSize => size != null ? _formatSize(size!) : 'Unknown size';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'createdTime': createdTime.toIso8601String(),
      'description': description,
      'size': size,
      'mimeType': mimeType,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'],
      name: map['name'],
      url: map['url'],
      createdTime: DateTime.parse(map['createdTime']),
      description: map['description'],
      size: map['size'],
      mimeType: map['mimeType'],
      isFavorite: map['isFavorite'] == 1,
    );
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}