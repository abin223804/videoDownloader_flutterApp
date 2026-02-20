// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloaded_video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadedVideoAdapter extends TypeAdapter<DownloadedVideo> {
  @override
  final int typeId = 0;

  @override
  DownloadedVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadedVideo(
      id: fields[0] as String,
      title: fields[1] as String,
      localPath: fields[2] as String,
      thumbnailPath: fields[3] as String?,
      fileSize: fields[4] as int,
      downloadedAt: fields[5] as DateTime,
      originalUrl: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadedVideo obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.localPath)
      ..writeByte(3)
      ..write(obj.thumbnailPath)
      ..writeByte(4)
      ..write(obj.fileSize)
      ..writeByte(5)
      ..write(obj.downloadedAt)
      ..writeByte(6)
      ..write(obj.originalUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
