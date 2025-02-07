import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'package:ts/models/photo.dart';
import 'package:ts/providers/photo_provider.dart';

class PhotoViewScreen extends StatelessWidget {
  final Photo photo;

  const PhotoViewScreen({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<PhotoProvider>(
            builder: (context, provider, child) {
              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      photo.isDownloaded ? Icons.download_done : Icons.download,
                      color: Colors.white,
                      size: _getIconSize(context),
                    ),
                    onPressed: () async {
                      try {
                        if (!photo.isDownloaded) {
                          await provider.downloadPhoto(photo);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Photo downloaded successfully')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to download photo')),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: Colors.white,
                      size: _getIconSize(context),
                    ),
                    onPressed: () async {
                      try {
                        await provider.sharePhoto(photo);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to share photo')),
                          );
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      photo.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: photo.isFavorite ? Colors.red : Colors.white,
                      size: _getIconSize(context),
                    ),
                    onPressed: () => provider.toggleFavorite(photo.id),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(photo.url),
            heroAttributes: PhotoViewHeroAttributes(tag: photo.id),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        itemCount: 1,
        loadingBuilder: (context, event) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            ),
          ),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }

  double _getIconSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 300) return 20;
    if (width <= 600) return 24;
    return 28;
  }
}
