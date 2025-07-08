import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/download_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/history_card.dart';
import '../services/instagram_service.dart';
import '../models/download_item.dart';
import '../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _urlController = TextEditingController();
  final InstagramService _instagramService = InstagramService();
  late TabController _tabController;
  
  bool _isLoading = false;
  List<DownloadItem> _downloadHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDownloadHistory();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadDownloadHistory() {
    // Load download history from local storage
    setState(() {
      _downloadHistory = _instagramService.getDownloadHistory();
    });
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _urlController.text = clipboardData.text!;
      });
    }
  }

  Future<void> _downloadContent() async {
    if (_urlController.text.isEmpty) {
      _showSnackBar('Please enter an Instagram URL');
      return;
    }

    if (!_isValidInstagramUrl(_urlController.text)) {
      _showSnackBar('Please enter a valid Instagram URL');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _instagramService.downloadContent(_urlController.text);
      if (result.success) {
        _showSnackBar('Download completed successfully!');
        _loadDownloadHistory();
        _urlController.clear();
      } else {
        _showSnackBar(result.message ?? 'Download failed');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isValidInstagramUrl(String url) {
    return url.contains('instagram.com') && 
           (url.contains('/p/') || url.contains('/reel/') || url.contains('/stories/'));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All in One Downloader'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      hintText: 'Paste Instagram URL here...',
                      prefixIcon: const Icon(Icons.link, color: Color(0xFF1976D2)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste, color: Color(0xFF1976D2)),
                        onPressed: _pasteFromClipboard,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 2,
                    minLines: 1,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _downloadContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.download_rounded),
                              SizedBox(width: 8),
                              Text('Download', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Features'),
                    Tab(text: 'History'),
                    Tab(text: 'About'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFeaturesTab(),
                      _buildHistoryTab(),
                      _buildAboutTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        FeatureCard(
          icon: Icons.video_library,
          title: 'Instagram Reels',
          description: 'Download Instagram Reels in high quality',
          color: Colors.purple,
        ),
        SizedBox(height: 12),
        FeatureCard(
          icon: Icons.photo_library,
          title: 'Instagram Posts',
          description: 'Save photos and carousel posts',
          color: Colors.blue,
        ),
        SizedBox(height: 12),
        FeatureCard(
          icon: Icons.auto_stories,
          title: 'Instagram Stories',
          description: 'Download stories before they disappear',
          color: Colors.orange,
        ),
        SizedBox(height: 12),
        FeatureCard(
          icon: Icons.high_quality,
          title: 'High Quality',
          description: 'Original quality downloads',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    if (_downloadHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No downloads yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Your download history will appear here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _downloadHistory.length,
      itemBuilder: (context, index) {
        return HistoryCard(item: _downloadHistory[index]);
      },
    );
  }

  Widget _buildAboutTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All in One Downloader',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Version 1.0.0'),
                const SizedBox(height: 16),
                const Text(
                  'A powerful Instagram content downloader that allows you to save reels, posts, and stories directly to your device.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• Download Instagram Reels'),
                const Text('• Save Instagram Posts'),
                const Text('• Download Instagram Stories'),
                const Text('• High quality downloads'),
                const Text('• Download history'),
                const Text('• Easy to use interface'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to use:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('1. Copy Instagram URL'),
                const Text('2. Paste it in the input field'),
                const Text('3. Tap Download button'),
                const Text('4. Wait for download to complete'),
                const SizedBox(height: 16),
                const Text(
                  'Supported URLs:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('• instagram.com/p/ (Posts)'),
                const Text('• instagram.com/reel/ (Reels)'),
                const Text('• instagram.com/stories/ (Stories)'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Information'),
        content: const Text(
          'All in One Downloader allows you to download Instagram content easily. '
          'Simply paste the Instagram URL and tap download.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

