import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/download_item.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  File? _historyFile;
  File? _settingsFile;
  List<DownloadItem> _downloadHistory = [];

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    _historyFile = File('${directory.path}/download_history.json');
    _settingsFile = File('${directory.path}/app_settings.json');
    
    await _loadDownloadHistory();
  }

  Future<void> _loadDownloadHistory() async {
    try {
      if (_historyFile != null && await _historyFile!.exists()) {
        final content = await _historyFile!.readAsString();
        final List<dynamic> jsonList = json.decode(content);
        _downloadHistory = jsonList
            .map((json) => DownloadItem.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading download history: $e');
      _downloadHistory = [];
    }
  }

  Future<void> _saveDownloadHistory() async {
    try {
      if (_historyFile != null) {
        final jsonList = _downloadHistory.map((item) => item.toJson()).toList();
        await _historyFile!.writeAsString(json.encode(jsonList));
      }
    } catch (e) {
      print('Error saving download history: $e');
    }
  }

  List<DownloadItem> getDownloadHistory() {
    return List.from(_downloadHistory.reversed);
  }

  Future<void> addDownloadItem(DownloadItem item) async {
    _downloadHistory.add(item);
    await _saveDownloadHistory();
  }

  Future<void> updateDownloadItem(DownloadItem updatedItem) async {
    final index = _downloadHistory.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _downloadHistory[index] = updatedItem;
      await _saveDownloadHistory();
    }
  }

  Future<void> deleteDownloadItem(String id) async {
    _downloadHistory.removeWhere((item) => item.id == id);
    await _saveDownloadHistory();
  }

  Future<void> clearDownloadHistory() async {
    _downloadHistory.clear();
    await _saveDownloadHistory();
  }

  DownloadItem? getDownloadItem(String id) {
    try {
      return _downloadHistory.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DownloadItem> getDownloadsByType(ContentType type) {
    return _downloadHistory.where((item) => item.type == type).toList();
  }

  List<DownloadItem> getDownloadsByStatus(DownloadStatus status) {
    return _downloadHistory.where((item) => item.status == status).toList();
  }

  int getTotalDownloads() {
    return _downloadHistory.length;
  }

  int getCompletedDownloads() {
    return _downloadHistory
        .where((item) => item.status == DownloadStatus.completed)
        .length;
  }

  int getFailedDownloads() {
    return _downloadHistory
        .where((item) => item.status == DownloadStatus.failed)
        .length;
  }

  // Settings management
  Future<Map<String, dynamic>> getSettings() async {
    try {
      if (_settingsFile != null && await _settingsFile!.exists()) {
        final content = await _settingsFile!.readAsString();
        return json.decode(content);
      }
    } catch (e) {
      print('Error loading settings: $e');
    }
    return _getDefaultSettings();
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      if (_settingsFile != null) {
        await _settingsFile!.writeAsString(json.encode(settings));
      }
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'downloadQuality': 'high',
      'saveToGallery': true,
      'showNotifications': true,
      'autoDownload': false,
      'downloadLocation': 'default',
      'theme': 'system',
    };
  }

  // File management
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
    return false;
  }

  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
    } catch (e) {
      print('Error getting file size: $e');
    }
    return 0;
  }

  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Error checking file existence: $e');
      return false;
    }
  }

  // Cache management
  Future<void> clearCache() async {
    try {
      final directory = await getTemporaryDirectory();
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<int> getCacheSize() async {
    try {
      final directory = await getTemporaryDirectory();
      if (await directory.exists()) {
        int totalSize = 0;
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
        return totalSize;
      }
    } catch (e) {
      print('Error calculating cache size: $e');
    }
    return 0;
  }
}

