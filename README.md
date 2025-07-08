# All in One Downloader

A powerful Flutter app for downloading Instagram content including reels, posts, and stories.

## Features

- 📱 **Instagram Reels Download** - Download Instagram Reels in high quality
- 🖼️ **Instagram Posts Download** - Save photos and carousel posts
- 📖 **Instagram Stories Download** - Download stories before they disappear
- 🎯 **High Quality Downloads** - Original quality content preservation
- 📱 **Modern UI** - Clean and intuitive user interface
- 📊 **Download History** - Track all your downloads
- 🔗 **URL Sharing** - Handle Instagram URLs shared from other apps
- 🎨 **Material Design** - Beautiful Material Design 3 interface

## Screenshots

The app features a modern, clean interface with:
- Splash screen with app branding
- Main download screen with URL input
- Tabbed interface for features, history, and about
- Download progress tracking
- History management with thumbnails

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK (API level 21 or higher)

### Setup

1. Clone or extract the project
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building APK

To build a release APK:
```bash
flutter build apk --release
```

## Usage

1. **Launch the app** - The splash screen will appear followed by the main interface
2. **Paste Instagram URL** - Copy an Instagram URL and paste it in the input field
3. **Download Content** - Tap the download button to start downloading
4. **View History** - Check the History tab to see all your downloads
5. **Share Content** - Use the share functionality to share downloaded content

### Supported URLs

- Instagram Posts: `https://instagram.com/p/[post-id]/`
- Instagram Reels: `https://instagram.com/reel/[reel-id]/`
- Instagram Stories: `https://instagram.com/stories/[username]/[story-id]/`

## Technical Details

### Architecture

- **Frontend**: Flutter with Material Design 3
- **Backend**: Native Android integration with Kotlin
- **Storage**: Local file system with gallery integration
- **Networking**: Dio HTTP client for downloads
- **State Management**: StatefulWidget with local state

### Key Components

- **Splash Screen**: Animated app introduction
- **Home Screen**: Main interface with tabbed navigation
- **Download Service**: Background download handling
- **Storage Service**: Local data persistence
- **Instagram Service**: Content extraction and downloading
- **Native Integration**: Android-specific functionality

### Permissions

The app requires the following permissions:
- Internet access for downloading content
- Storage access for saving files
- Media access for gallery integration
- Notification access for download progress

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── download_item.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   └── home_screen.dart
├── widgets/                  # Reusable widgets
│   ├── feature_card.dart
│   ├── history_card.dart
│   └── download_card.dart
├── services/                 # Business logic
│   ├── instagram_service.dart
│   └── storage_service.dart
└── utils/                    # Utilities
    ├── constants.dart
    └── date_formatter.dart

android/
├── app/
│   ├── src/main/kotlin/      # Native Android code
│   └── build.gradle          # Android build configuration
└── build.gradle              # Project build configuration
```

## Dependencies

### Flutter Dependencies
- `http`: HTTP requests
- `dio`: Advanced HTTP client
- `path_provider`: File system access
- `permission_handler`: Runtime permissions
- `flutter_downloader`: Download management
- `gallery_saver`: Save to device gallery
- `cached_network_image`: Image caching
- `video_player`: Video playback
- `share_plus`: Content sharing
- `fluttertoast`: Toast notifications

### Android Dependencies
- Kotlin coroutines for async operations
- AndroidX libraries for modern Android development
- Work Manager for background tasks

## Future Enhancements

- Support for more social media platforms
- Batch download functionality
- Download scheduling
- Cloud storage integration
- Advanced filtering and search
- Download quality selection
- Dark theme support
- Multi-language support

## Legal Notice

This app is for educational purposes only. Users are responsible for complying with Instagram's Terms of Service and applicable copyright laws. The developers are not responsible for any misuse of this application.

## License

This project is for educational and personal use only. Please respect content creators' rights and Instagram's terms of service.

## Support

For issues and feature requests, please create an issue in the project repository.

---

**Note**: This is a demo application. In a production environment, you would need to implement proper Instagram API integration or use authorized methods for content access.

