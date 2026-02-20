import '../../domain/entities/media_info.dart';
import '../../domain/repositories/downloader_repository.dart';
import '../../../../core/network/api_client.dart';

class DownloaderRepositoryImpl implements DownloaderRepository {
  final ApiClient apiClient;

  DownloaderRepositoryImpl({required this.apiClient});

  @override
  Future<MediaInfo> extractMetadata(String url) async {
    final response = await apiClient.post('/media/extract', data: {'url': url});
    return MediaInfo.fromJson(response.data);
  }

  @override
  Future<String> getDownloadUrl(String url, String formatId) async {
    final response = await apiClient.post('/media/download', data: {
      'url': url,
      'formatId': formatId,
    });
    return response.data['url'] as String;
  }
}
