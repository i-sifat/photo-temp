import 'package:flutter/material.dart';
import 'package:ts/models/photo.dart';
import 'package:ts/services/drive_service.dart';
import 'package:ts/services/database_service.dart';
import 'package:ts/services/photo_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PhotoProvider with ChangeNotifier {
  final DriveService _driveService = DriveService();
  final DatabaseService _databaseService = DatabaseService();
  final PhotoService _photoService = PhotoService();
  final Connectivity _connectivity = Connectivity();

  List<Photo> _photos = [];
  List<Photo> _filteredPhotos = [];
  bool _isLoading = false;
  String? _error;
  String? _nextPageToken;
  bool _hasMore = true;
  bool _isOffline = false;
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  List<Photo> get photos =>
      _searchQuery.isEmpty && _startDate == null && _endDate == null
          ? _photos
          : _filteredPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  bool get isOffline => _isOffline;

  PhotoProvider() {
    _setupConnectivityListener();
  }

  void _setupConnectivityListener() {
    _connectivity.onConnectivityChanged.listen((result) async {
      final wasOffline = _isOffline;
      _isOffline = result == ConnectivityResult.none;

      if (wasOffline && !_isOffline) {
        await _syncWithServer();
      }
      notifyListeners();
    });
  }

  Future<void> initialize(String apiKey) async {
    try {
      await _driveService.initialize(apiKey);
      await _loadCachedPhotos();

      final connectivityResult = await _connectivity.checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;

      if (!_isOffline) {
        await _syncWithServer();
      }
    } catch (e) {
      _error = 'Failed to initialize: ${e.toString()}';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<void> _loadCachedPhotos() async {
    try {
      _photos = await _databaseService.getPhotos();
    } catch (e) {
      _error = 'Failed to load cached photos: ${e.toString()}';
      debugPrint(_error);
    }
    notifyListeners();
  }

  Future<void> _syncWithServer() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final lastSyncTime = await _databaseService.getLastSyncTime();
      final newPhotos = await _driveService.fetchPhotosAfter(lastSyncTime);

      if (newPhotos.isNotEmpty) {
        await _databaseService.savePhotos(newPhotos);
        _photos.addAll(newPhotos);
        _photos.sort((a, b) => b.createdTime.compareTo(a.createdTime));
        await _databaseService.updateLastSyncTime();
      }
    } catch (e) {
      _error = 'Failed to sync with server: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPhotos(String folderId) async {
    if (_isLoading || !_hasMore || _isOffline) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPhotos = await _driveService.fetchPhotos(
        folderId: folderId,
        pageToken: _nextPageToken,
      );

      if (newPhotos.isEmpty) {
        _hasMore = false;
      } else {
        _photos.addAll(newPhotos);
        await _databaseService.savePhotos(newPhotos);
      }
    } catch (e) {
      _error = 'Failed to fetch photos: ${e.toString()}';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> downloadPhoto(Photo photo) async {
    try {
      final localPath = await _photoService.downloadPhoto(
          photo.url, '${photo.id}_${photo.name}');
      await _databaseService.updatePhotoDownloadStatus(
          photo.id, true, localPath);

      final index = _photos.indexWhere((p) => p.id == photo.id);
      if (index != -1) {
        _photos[index].isDownloaded = true;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to download photo: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    }
  }

  Future<void> sharePhoto(Photo photo, {String? caption}) async {
    try {
      if (!photo.isDownloaded) {
        await downloadPhoto(photo);
      }
      final localPath = (await _databaseService.getPhotos())
          .firstWhere((p) => p.id == photo.id)
          .url;
      await _photoService.sharePhoto(localPath, caption);
    } catch (e) {
      _error = 'Failed to share photo: ${e.toString()}';
      debugPrint(_error);
      rethrow;
    }
  }

  void search(String query) {
    _searchQuery = query.toLowerCase();
    _filterPhotos();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _filterPhotos();
  }

  void _filterPhotos() {
    _filteredPhotos = _photos.where((photo) {
      bool matchesSearch = _searchQuery.isEmpty ||
          photo.name.toLowerCase().contains(_searchQuery) ||
          (photo.description?.toLowerCase().contains(_searchQuery) ?? false);

      bool matchesDateRange = true;
      if (_startDate != null) {
        matchesDateRange =
            matchesDateRange && photo.createdTime.isAfter(_startDate!);
      }
      if (_endDate != null) {
        matchesDateRange =
            matchesDateRange && photo.createdTime.isBefore(_endDate!);
      }

      return matchesSearch && matchesDateRange;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _startDate = null;
    _endDate = null;
    _filteredPhotos.clear();
    notifyListeners();
  }

  Future<void> toggleFavorite(String photoId) async {
    try {
      final index = _photos.indexWhere((photo) => photo.id == photoId);
      if (index != -1) {
        _photos[index].isFavorite = !_photos[index].isFavorite;
        await _databaseService.updatePhoto(_photos[index]);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      debugPrint(_error);
    }
  }

  List<Photo> getFavorites() {
    return _photos.where((photo) => photo.isFavorite).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
