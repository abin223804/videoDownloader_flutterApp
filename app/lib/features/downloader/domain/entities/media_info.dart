import 'media_format.dart';

class MediaInfo {
  final String title;
  final String? thumbnail;
  final int? duration;
  final String extractor;
  final List<MediaFormat> formats;

  MediaInfo({
    required this.title,
    this.thumbnail,
    this.duration,
    required this.extractor,
    required this.formats,
  });

  factory MediaInfo.fromJson(Map<String, dynamic> json) {
    return MediaInfo(
      title: json['title'] ?? 'Unknown Title',
      thumbnail: json['thumbnail'],
      duration: json['duration'],
      extractor: json['extractor'] ?? 'unknown',
      formats: (json['formats'] as List?)
              ?.map((f) => MediaFormat.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
