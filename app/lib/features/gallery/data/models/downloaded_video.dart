import 'package:hive/hive.dart';

part 'downloaded_video.g.dart';

@HiveType(typeId: 0)
class DownloadedVideo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String localPath;

  @HiveField(3)
  String? thumbnailPath;

  @HiveField(4)
  int fileSize;

  @HiveField(5)
  DateTime downloadedAt;

  @HiveField(6)
  String originalUrl;

  DownloadedVideo({
    required this.id,
    required this.title,
    required this.localPath,
    this.thumbnailPath,
    required this.fileSize,
    required this.downloadedAt,
    required this.originalUrl,
  });
}
