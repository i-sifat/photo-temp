import 'package:flutter/material.dart';
import 'package:ts/models/photo.dart';

class PhotoDetails extends StatelessWidget {
  final Photo photo;

  const PhotoDetails({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            photo.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (photo.description != null) ...[
            Text(
              photo.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(
            context,
            Icons.calendar_today,
            'Created: ${photo.formattedDate}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.photo_size_select_actual,
            photo.formattedSize,
          ),
          if (photo.mimeType != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              Icons.file_present,
              photo.mimeType!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}