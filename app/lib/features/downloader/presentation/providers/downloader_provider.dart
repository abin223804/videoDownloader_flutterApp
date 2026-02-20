import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/media_info.dart';
import '../../domain/repositories/downloader_repository.dart';
import '../../data/repositories/downloader_repository_impl.dart';
import '../../../../core/network/api_client.dart';

// Provides the ApiClient instance
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(Dio());
});

// Provides the DownloaderRepository implementation
final downloaderRepositoryProvider = Provider<DownloaderRepository>((ref) {
  return DownloaderRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

// Defines the state for our downloader screen
class DownloaderState {
  final bool isLoading;
  final String? error;
  final MediaInfo? mediaInfo;

  DownloaderState({this.isLoading = false, this.error, this.mediaInfo});

  DownloaderState copyWith({bool? isLoading, String? error, MediaInfo? mediaInfo}) {
    return DownloaderState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // To clear the error, we pass null and it naturally overwrites
      mediaInfo: mediaInfo ?? this.mediaInfo,
    );
  }
}

class DownloaderNotifier extends Notifier<DownloaderState> {
  late final DownloaderRepository repository;

  @override
  DownloaderState build() {
    repository = ref.watch(downloaderRepositoryProvider);
    return DownloaderState();
  }

  Future<void> extractMediaInfo(String url) async {
    if (url.isEmpty || !Uri.parse(url).isAbsolute) {
      state = state.copyWith(error: 'Please enter a valid URL');
      return;
    }
    state = DownloaderState(isLoading: true); 
    try {
      final info = await repository.extractMetadata(url);
      state = state.copyWith(isLoading: false, mediaInfo: info);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearSearch() {
    state = DownloaderState();
  }
}

final downloaderProvider = NotifierProvider<DownloaderNotifier, DownloaderState>(() {
  return DownloaderNotifier();
});
