import 'package:flutter/material.dart';
import '../models/download_item.dart';

class DownloadCard extends StatelessWidget {
  final DownloadItem item;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const DownloadCard({
    super.key,
    required this.item,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTypeIcon(item.type),
                  color: _getTypeColor(item.type),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.title ?? 'Instagram ${item.type.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusIcon(),
              ],
            ),
            const SizedBox(height: 12),
            if (item.status == DownloadStatus.downloading) ...[
              LinearProgressIndicator(
                value: item.progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTypeColor(item.type),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                ],
              ),
            ] else if (item.status == DownloadStatus.failed) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Download failed',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
                    ),
                ],
              ),
            ] else if (item.status == DownloadStatus.completed) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[600],
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Download completed',
                    style: TextStyle(
                      color: Colors.green[600],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openFile(context),
                    child: const Text('Open'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (item.status) {
      case DownloadStatus.downloading:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case DownloadStatus.completed:
        return Icon(
          Icons.check_circle,
          color: Colors.green[600],
          size: 20,
        );
      case DownloadStatus.failed:
        return Icon(
          Icons.error,
          color: Colors.red[600],
          size: 20,
        );
      case DownloadStatus.pending:
        return Icon(
          Icons.schedule,
          color: Colors.orange[600],
          size: 20,
        );
    }
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

  void _openFile(BuildContext context) {
    // Implement file opening functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening file...')),
    );
  }
}

