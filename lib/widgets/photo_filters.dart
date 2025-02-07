import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ts/providers/photo_provider.dart';

class PhotoFilters extends StatelessWidget {
  const PhotoFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            hintText: 'Search photos...',
            onChanged: (query) {
              Provider.of<PhotoProvider>(context, listen: false).search(query);
            },
            leading: const Icon(Icons.search),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('Filter by date'),
          onTap: () => _showDateRangePicker(context),
        ),
      ],
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null && context.mounted) {
      Provider.of<PhotoProvider>(context, listen: false)
        .setDateRange(dateRange.start, dateRange.end);
    }
  }
}