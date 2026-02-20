import '../entities/media_info.dart';

abstract class DownloaderRepository {
  /// Extracts metadata and available formats for a video URL.
  Future<MediaInfo> extractMetadata(String url);

  /// Gets the direct streaming URL for downloading.
  Future<String> getDownloadUrl(String url, String formatId);
}
