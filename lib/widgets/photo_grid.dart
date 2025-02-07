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
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: photos.length + (isLoading ? 6 : 0),
      itemBuilder: (context, index) {
        if (index >= photos.length) {
          return _buildShimmerItem();
        }

        final photo = photos[index];
        return _buildPhotoItem(context, photo);
      },
    );
  }

  Widget _buildPhotoItem(BuildContext context, Photo photo) {
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
            child: IconButton(
              icon: Icon(
                photo.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: photo.isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () => onFavoriteToggle(photo.id),
            ),
          ),
        ],
      ),
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