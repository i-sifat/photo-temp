import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts/providers/photo_provider.dart';
import 'package:ts/widgets/photo_grid.dart';
import 'package:ts/widgets/photo_filters.dart';
import 'package:ts/widgets/offline_banner.dart';
import 'package:ts/widgets/error_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializePhotos();
  }

  Future<void> _initializePhotos() async {
    final provider = Provider.of<PhotoProvider>(context, listen: false);
    // TODO: Replace with your Google Drive API key
    await provider.initialize('YOUR_API_KEY');
    // TODO: Replace with your Google Drive folder ID
    await provider.fetchPhotos('YOUR_FOLDER_ID');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = Provider.of<PhotoProvider>(context, listen: false);
      if (!provider.isLoading && provider.hasMore) {
        // TODO: Replace with your Google Drive folder ID
        provider.fetchPhotos('YOUR_FOLDER_ID');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PhotoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              if (provider.isOffline) const OfflineBanner(),
              if (provider.error != null)
                ErrorBanner(
                  message: provider.error!,
                  onDismiss: provider.clearError,
                ),
              const PhotoFilters(),
              Expanded(
                child: PhotoGrid(
                  photos: provider.photos,
                  isLoading: provider.isLoading,
                  onLoadMore: provider.hasMore ? () {
                    // TODO: Replace with your Google Drive folder ID
                    provider.fetchPhotos('YOUR_FOLDER_ID');
                  } : null,
                  onFavoriteToggle: provider.toggleFavorite,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}