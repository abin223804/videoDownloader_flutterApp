import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/downloader_provider.dart';
import '../../domain/entities/media_info.dart';
import '../../../gallery/presentation/screens/gallery_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _onExtractPressed() {
    FocusScope.of(context).unfocus();
    ref.read(downloaderProvider.notifier).extractMediaInfo(_urlController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(downloaderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MediaSaver Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => GalleryScreen()));
            },
            tooltip: 'Gallery',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            tooltip: 'Settings',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // URL Input Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        labelText: 'Paste Video URL',
                        hintText: 'https://youtube.com/... or https://instagram.com/...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _urlController.clear();
                            ref.read(downloaderProvider.notifier).clearSearch();
                          },
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _onExtractPressed(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: state.isLoading ? null : _onExtractPressed,
                        icon: state.isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.search),
                        label: Text(state.isLoading ? 'Extracting...' : 'Extract Media'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Error Display
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),

            // Preview Section
            if (state.mediaInfo != null)
              Expanded(
                child: _buildMediaPreview(context, state.mediaInfo!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(BuildContext context, MediaInfo info) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (info.thumbnail != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                info.thumbnail!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            info.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Chip(label: Text(info.extractor.toUpperCase())),
              const SizedBox(width: 8),
              if (info.duration != null)
                Chip(
                  label: Text('${(info.duration! / 60).floor()}:${(info.duration! % 60).toString().padLeft(2, '0')}'),
                  avatar: const Icon(Icons.timer, size: 16),
                ),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Available Formats',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ...info.formats.map((format) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.video_file),
            title: Text('${format.resolution} (${format.ext})'),
            subtitle: format.filesize != null 
                ? Text('${(format.filesize! / (1024 * 1024)).toStringAsFixed(1)} MB')
                : const Text('Size Unknown'),
            trailing: FilledButton.tonal(
              onPressed: () => _initiateDownload(context, info, format.formatId),
              child: const Text('Download'),
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _initiateDownload(BuildContext context, MediaInfo info, String formatId) async {
    // Request storage and notification permissions
    var status = await Permission.storage.request();
    var notificationStatus = await Permission.notification.request();

    if (!status.isGranted) {
      if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Storage permission is required to save videos.')));
      }
      return;
    }

    try {
      // Get the actual direct stream URL from our Node.js Backend
      final downloadUrl = await ref.read(downloaderProvider.notifier).repository.getDownloadUrl(info.extractor.toLowerCase() == 'youtube' ? _urlController.text : _urlController.text, formatId); // Backend takes the URL and format string
      final dir = await getApplicationDocumentsDirectory();
      
      final taskId = await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: dir.path,
        fileName: '${info.title.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_')}_$formatId.mp4',
        showNotification: true,
        openFileFromNotification: true,
        saveInPublicStorage: true,
      );

      if (context.mounted && taskId != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Download started...')));
      }

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start download: $e')));
      }
    }
  }
}
