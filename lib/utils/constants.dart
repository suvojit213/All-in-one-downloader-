class AppConstants {
  static const String appName = 'All in One Downloader';
  static const String appVersion = '1.0.0';
  
  // Instagram URL patterns
  static const String instagramDomain = 'instagram.com';
  static const String postPattern = '/p/';
  static const String reelPattern = '/reel/';
  static const String storyPattern = '/stories/';
  
  // Download settings
  static const int maxConcurrentDownloads = 3;
  static const int downloadTimeoutSeconds = 30;
  static const String downloadDirectory = 'All_in_One_Downloader';
  
  // File extensions
  static const String videoExtension = '.mp4';
  static const String imageExtension = '.jpg';
  
  // API endpoints (placeholder - would need actual Instagram API)
  static const String baseApiUrl = 'https://api.instagram.com';
  
  // Storage keys
  static const String downloadHistoryKey = 'download_history';
  static const String settingsKey = 'app_settings';
  
  // Error messages
  static const String invalidUrlError = 'Please enter a valid Instagram URL';
  static const String networkError = 'Network error. Please check your connection';
  static const String downloadError = 'Download failed. Please try again';
  static const String permissionError = 'Storage permission required';
  
  // Success messages
  static const String downloadSuccess = 'Download completed successfully!';
  static const String downloadStarted = 'Download started';
  
  // Supported content types
  static const List<String> supportedTypes = ['reel', 'post', 'story'];
  
  // UI constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  
  // Colors
  static const int primaryColorValue = 0xFF1976D2;
  static const int accentColorValue = 0xFF2196F3;
  
  // Animation durations
  static const int splashDurationSeconds = 3;
  static const int animationDurationMs = 300;
}

class RegexPatterns {
  static const String instagramUrl = r'https?://(?:www\.)?instagram\.com/(?:p|reel|stories)/([a-zA-Z0-9_-]+)/?';
  static const String instagramPost = r'https?://(?:www\.)?instagram\.com/p/([a-zA-Z0-9_-]+)/?';
  static const String instagramReel = r'https?://(?:www\.)?instagram\.com/reel/([a-zA-Z0-9_-]+)/?';
  static const String instagramStory = r'https?://(?:www\.)?instagram\.com/stories/([a-zA-Z0-9_-]+)/([0-9]+)/?';
}

