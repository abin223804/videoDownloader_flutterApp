import 'dart:isolate';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadTaskInfo {
  final String taskId;
  final DownloadTaskStatus status;
  final int progress;

  DownloadTaskInfo({required this.taskId, required this.status, required this.progress});
}

class DownloadManagerNotifier extends StateNotifier<Map<String, DownloadTaskInfo>> {
  final ReceivePort _port = ReceivePort();

  DownloadManagerNotifier() : super({}) {
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _bindBackgroundIsolate() {
    final isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      final String id = data[0];
      final DownloadTaskStatus status = DownloadTaskStatus.fromInt(data[1]);
      final int progress = data[2];

      state = {
        ...state,
        id: DownloadTaskInfo(taskId: id, status: status, progress: progress)
      };
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send(String id, int status, int progress) {
      return IsolateNameServer.lookupPortByName('downloader_send_port');
    }
    final port = send(id, status, progress);
    port?.send([id, status, progress]);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }
}

final downloadManagerProvider = StateNotifierProvider<DownloadManagerNotifier, Map<String, DownloadTaskInfo>>((ref) {
  return DownloadManagerNotifier();
});
