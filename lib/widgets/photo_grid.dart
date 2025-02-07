import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ts/models/photo.dart';
import 'package:ts/screens/photo_view_screen.dart';

class PhotoGrid extends StatelessWidget {
  final List<Photo> photos;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final Function(String) onFavoriteToggle;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.isLoading,
    this.onLoadMore,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _calculateCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: photos.length + (isLoading ? crossAxisCount * 2 : 0),
          itemBuilder: (context, index) {
            if (index >= photos.length) {
              return _buildShimmerItem();
            }

            final photo = photos[index];
            return _buildPhotoItem(context, photo);
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width <= 300) return 2;
    if (width <= 600) return 3;
    if (width <= 900) return 4;
    return 5;
  }

  Widget _buildPhotoItem(BuildContext context, Photo photo) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth;
        final iconSize = size * 0.2;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PhotoViewScreen(photo: photo),
              ),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: photo.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: photo.url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildShimmerItem(),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(iconSize / 2),
                  ),
                  child: IconButton(
                    icon: Icon(
                      photo.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: photo.isFavorite ? Colors.red : Colors.white,
                      size: iconSize,
                    ),
                    iconSize: iconSize,
                    padding: EdgeInsets.all(iconSize / 4),
                    constraints: BoxConstraints(
                      minWidth: iconSize * 1.5,
                      minHeight: iconSize * 1.5,
                    ),
                    onPressed: () => onFavoriteToggle(photo.id),
                  ),
                ),
              ),
              if (photo.isDownloaded)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.download_done,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
