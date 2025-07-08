enum ContentType {
  reel,
  post,
  story,
}

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
}

class DownloadItem {
  final String id;
  final String url;
  final ContentType type;
  final String? title;
  final String? thumbnailUrl;
  final String? filePath;
  final DateTime downloadDate;
  final DownloadStatus status;
  final double progress;
  final String? errorMessage;
  final int? fileSize;

  DownloadItem({
    required this.id,
    required this.url,
    required this.type,
    this.title,
    this.thumbnailUrl,
    this.filePath,
    required this.downloadDate,
    this.status = DownloadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    this.fileSize,
  });

  DownloadItem copyWith({
    String? id,
    String? url,
    ContentType? type,
    String? title,
    String? thumbnailUrl,
    String? filePath,
    DateTime? downloadDate,
    DownloadStatus? status,
    double? progress,
    String? errorMessage,
    int? fileSize,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      url: url ?? this.url,
      type: type ?? this.type,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      filePath: filePath ?? this.filePath,
      downloadDate: downloadDate ?? this.downloadDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'type': type.name,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'filePath': filePath,
      'downloadDate': downloadDate.toIso8601String(),
      'status': status.name,
      'progress': progress,
      'errorMessage': errorMessage,
      'fileSize': fileSize,
    };
  }

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      id: json['id'],
      url: json['url'],
      type: ContentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContentType.post,
      ),
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      filePath: json['filePath'],
      downloadDate: DateTime.parse(json['downloadDate']),
      status: DownloadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DownloadStatus.pending,
      ),
      progress: json['progress']?.toDouble() ?? 0.0,
      errorMessage: json['errorMessage'],
      fileSize: json['fileSize'],
    );
  }
}

class DownloadResult {
  final bool success;
  final String? message;
  final DownloadItem? item;

  DownloadResult({
    required this.success,
    this.message,
    this.item,
  });
}

