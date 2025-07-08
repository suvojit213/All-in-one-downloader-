import 'package:flutter/services.dart';
import 'dart:io';

class NativeService {
  static const MethodChannel _channel = MethodChannel('com.example.all_in_one_downloader/native');
  
  static final NativeService _instance = NativeService._internal();
  factory NativeService() => _instance;
  NativeService._internal() {
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onUrlReceived':
          final String url = call.arguments['url'];
          await _handleReceivedUrl(url);
          break;
        default:
          throw MissingPluginException('Method ${call.method} not implemented');
      }
    });
  }

  Future<void> _handleReceivedUrl(String url) async {
    // Handle URL received from Android intent
    print('Received URL from Android: $url');
    // You can implement navigation or state management here
  }

  Future<void> showToast(String message) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('showToast', {'message': message});
      } catch (e) {
        print('Error showing toast: $e');
      }
    }
  }

  Future<bool> shareFile(String filePath, String mimeType) async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('shareFile', {
          'filePath': filePath,
          'mimeType': mimeType,
        });
        return result ?? false;
      } catch (e) {
        print('Error sharing file: $e');
        return false;
      }
    }
    return false;
  }

  Future<bool> openFile(String filePath, String mimeType) async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('openFile', {
          'filePath': filePath,
          'mimeType': mimeType,
        });
        return result ?? false;
      } catch (e) {
        print('Error opening file: $e');
        return false;
      }
    }
    return false;
  }

  Future<String?> getIntentData() async {
    if (Platform.isAndroid) {
      try {
        final result = await _channel.invokeMethod('getIntentData');
        return result;
      } catch (e) {
        print('Error getting intent data: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> clearIntentData() async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('clearIntentData');
      } catch (e) {
        print('Error clearing intent data: $e');
      }
    }
  }

  String getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> startDownloadService(String url, String fileName, String downloadPath) async {
    if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('startDownloadService', {
          'url': url,
          'fileName': fileName,
          'downloadPath': downloadPath,
        });
      } catch (e) {
        print('Error starting download service: $e');
      }
    }
  }
}

