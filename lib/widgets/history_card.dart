import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/download_item.dart';
import '../utils/date_formatter.dart';

class HistoryCard extends StatelessWidget {
  final DownloadItem item;

  const HistoryCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: item.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          _getTypeIcon(item.type),
                          color: Colors.grey[600],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Instagram ${item.type.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatDate(item.downloadDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(item.type).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getTypeColor(item.type),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        item.status == DownloadStatus.completed
                            ? Icons.check_circle
                            : item.status == DownloadStatus.failed
                                ? Icons.error
                                : Icons.downloading,
                        size: 16,
                        color: item.status == DownloadStatus.completed
                            ? Colors.green
                            : item.status == DownloadStatus.failed
                                ? Colors.red
                                : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _shareItem(context, item);
                    break;
                  case 'delete':
                    _deleteItem(context, item);
                    break;
                  case 'redownload':
                    _redownloadItem(context, item);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'redownload',
                  child: Row(
                    children: [
                      Icon(Icons.refresh),
                      SizedBox(width: 8),
                      Text('Redownload'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ContentType type) {
    switch (type) {
      case ContentType.reel:
        return Icons.video_library;
      case ContentType.post:
        return Icons.photo_library;
      case ContentType.story:
        return Icons.auto_stories;
    }
  }

  Color _getTypeColor(ContentType type) {
    switch (type) {
      case ContentType.reel:
        return Colors.purple;
      case ContentType.post:
        return Colors.blue;
      case ContentType.story:
        return Colors.orange;
    }
  }

  void _shareItem(BuildContext context, DownloadItem item) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _deleteItem(BuildContext context, DownloadItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _redownloadItem(BuildContext context, DownloadItem item) {
    // Implement redownload functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redownload started')),
    );
  }
}

