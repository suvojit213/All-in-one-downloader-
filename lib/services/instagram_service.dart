import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../models/download_item.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class InstagramService {
  final Dio _dio = Dio();
  final StorageService _storageService = StorageService();
  
  InstagramService() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    };
  }

  Future<DownloadResult> downloadContent(String url) async {
    try {
      // Check permissions
      if (!await _checkPermissions()) {
        return DownloadResult(
          success: false,
          message: AppConstants.permissionError,
        );
      }

      // Parse URL and determine content type
      final contentInfo = _parseInstagramUrl(url);
      if (contentInfo == null) {
        return DownloadResult(
          success: false,
          message: AppConstants.invalidUrlError,
        );
      }

      // Create download item
      final downloadItem = DownloadItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: url,
        type: contentInfo['type'],
        downloadDate: DateTime.now(),
        status: DownloadStatus.downloading,
      );

      // Save to history
      await _storageService.addDownloadItem(downloadItem);

      // Extract content information
      final contentData = await _extractContentData(url, contentInfo['type']);
      if (contentData == null) {
        final failedItem = downloadItem.copyWith(
          status: DownloadStatus.failed,
          errorMessage: 'Failed to extract content data',
        );
        await _storageService.updateDownloadItem(failedItem);
        return DownloadResult(
          success: false,
          message: 'Failed to extract content data',
          item: failedItem,
        );
      }

      // Download the actual content
      final downloadPath = await _downloadFile(
        contentData['downloadUrl'],
        contentData['filename'],
        downloadItem,
      );

      if (downloadPath != null) {
        // Save to gallery
        await _saveToGallery(downloadPath, contentInfo['type']);
        
        final completedItem = downloadItem.copyWith(
          status: DownloadStatus.completed,
          filePath: downloadPath,
          title: contentData['title'],
          thumbnailUrl: contentData['thumbnail'],
          progress: 1.0,
        );
        
        await _storageService.updateDownloadItem(completedItem);
        
        return DownloadResult(
          success: true,
          message: AppConstants.downloadSuccess,
          item: completedItem,
        );
      } else {
        final failedItem = downloadItem.copyWith(
          status: DownloadStatus.failed,
          errorMessage: AppConstants.downloadError,
        );
        await _storageService.updateDownloadItem(failedItem);
        return DownloadResult(
          success: false,
          message: AppConstants.downloadError,
          item: failedItem,
        );
      }
    } catch (e) {
      return DownloadResult(
        success: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  Map<String, dynamic>? _parseInstagramUrl(String url) {
    // Check for post
    if (url.contains(AppConstants.postPattern)) {
      final regex = RegExp(RegexPatterns.instagramPost);
      final match = regex.firstMatch(url);
      if (match != null) {
        return {
          'type': ContentType.post,
          'id': match.group(1),
        };
      }
    }
    
    // Check for reel
    if (url.contains(AppConstants.reelPattern)) {
      final regex = RegExp(RegexPatterns.instagramReel);
      final match = regex.firstMatch(url);
      if (match != null) {
        return {
          'type': ContentType.reel,
          'id': match.group(1),
        };
      }
    }
    
    // Check for story
    if (url.contains(AppConstants.storyPattern)) {
      final regex = RegExp(RegexPatterns.instagramStory);
      final match = regex.firstMatch(url);
      if (match != null) {
        return {
          'type': ContentType.story,
          'id': match.group(1),
          'storyId': match.group(2),
        };
      }
    }
    
    return null;
  }

  Future<Map<String, dynamic>?> _extractContentData(String url, ContentType type) async {
    try {
      // This is a simplified implementation
      // In a real app, you would need to use Instagram's API or web scraping
      // For demo purposes, we'll simulate the extraction
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
      
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final extension = type == ContentType.post ? AppConstants.imageExtension : AppConstants.videoExtension;
      
      return {
        'downloadUrl': _generateDemoUrl(type),
        'filename': '${type.name}_$id$extension',
        'title': 'Instagram ${type.name.toUpperCase()}',
        'thumbnail': _generateDemoThumbnail(type),
      };
    } catch (e) {
      print('Error extracting content data: $e');
      return null;
    }
  }

  String _generateDemoUrl(ContentType type) {
    // Demo URLs for testing - in real app, these would be actual Instagram content URLs
    switch (type) {
      case ContentType.reel:
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4';
      case ContentType.post:
        return 'https://picsum.photos/1080/1080';
      case ContentType.story:
        return 'https://sample-videos.com/zip/10/mp4/SampleVideo_640x360_1mb.mp4';
    }
  }

  String _generateDemoThumbnail(ContentType type) {
    return 'https://picsum.photos/300/300';
  }

  Future<String?> _downloadFile(String url, String filename, DownloadItem item) async {
    try {
      final directory = await _getDownloadDirectory();
      final filePath = '${directory.path}/$filename';
      
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            final updatedItem = item.copyWith(progress: progress);
            _storageService.updateDownloadItem(updatedItem);
          }
        },
      );
      
      return filePath;
    } catch (e) {
      print('Error downloading file: $e');
      return null;
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      if (directory != null) {
        directory = Directory('${directory.path}/${AppConstants.downloadDirectory}');
      }
    } else {
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/${AppConstants.downloadDirectory}');
    }
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }

  Future<bool> _checkPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return true;
  }

  Future<void> _saveToGallery(String filePath, ContentType type) async {
    try {
      if (type == ContentType.post) {
        await GallerySaver.saveImage(filePath);
      } else {
        await GallerySaver.saveVideo(filePath);
      }
    } catch (e) {
      print('Error saving to gallery: $e');
    }
  }

  List<DownloadItem> getDownloadHistory() {
    return _storageService.getDownloadHistory();
  }

  Future<void> clearDownloadHistory() async {
    await _storageService.clearDownloadHistory();
  }

  Future<void> deleteDownloadItem(String id) async {
    await _storageService.deleteDownloadItem(id);
  }
}

