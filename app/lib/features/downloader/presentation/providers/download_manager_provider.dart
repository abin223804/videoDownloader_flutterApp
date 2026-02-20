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

class DownloadManagerNotifier extends Notifier<Map<String, DownloadTaskInfo>> {
  final ReceivePort _port = ReceivePort();

  @override
  Map<String, DownloadTaskInfo> build() {
    // Keep reference so it isn't garbage collected
    ref.onDispose(() => _unbindBackgroundIsolate());
    
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
    
    return {};
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
    SendPort? send(String id, int status, int progress) {
      return IsolateNameServer.lookupPortByName('downloader_send_port');
    }
    final port = send(id, status, progress);
    port?.send([id, status, progress]);
  }
}

final downloadManagerProvider = NotifierProvider<DownloadManagerNotifier, Map<String, DownloadTaskInfo>>(() {
  return DownloadManagerNotifier();
});
