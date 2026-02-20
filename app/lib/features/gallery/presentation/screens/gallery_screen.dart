import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/downloaded_video.dart';
import 'video_player_screen.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads Gallery'),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<DownloadedVideo>('downloads').listenable(),
        builder: (context, Box<DownloadedVideo> box, _) {
          if (box.values.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.video_library_outlined, size: 80, color: Colors.grey[400]),
                   const SizedBox(height: 16),
                   Text('No downloaded videos yet.', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: box.values.length,
            itemBuilder: (context, index) {
              final video = box.getAt(index);
              if (video == null) return const SizedBox.shrink();

              return ListTile(
                leading: video.thumbnailPath != null 
                    ? Image.network(video.thumbnailPath!, width: 60, height: 60, fit: BoxFit.cover)
                    : const Icon(Icons.video_file, size: 40),
                title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('${(video.fileSize / (1024 * 1024)).toStringAsFixed(1)} MB'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                         Share.shareXFiles([XFile(video.localPath)], text: 'Check out this video: ${video.title}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                           builder: (_) => VideoPlayerScreen(videoPath: video.localPath, title: video.title)
                        ));
                      },
                    ),
                  ],
                ),
                onLongPress: () {
                  _showDeleteDialog(context, box, index);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Box<DownloadedVideo> box, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Video'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () {
              box.deleteAt(index);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Video deleted')));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
  }
}
