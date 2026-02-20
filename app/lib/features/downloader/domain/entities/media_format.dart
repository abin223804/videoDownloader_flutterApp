class MediaFormat {
  final String formatId;
  final String ext;
  final String resolution;
  final int? filesize;
  final String? vcodec;
  final String? acodec;

  MediaFormat({
    required this.formatId,
    required this.ext,
    required this.resolution,
    this.filesize,
    this.vcodec,
    this.acodec,
  });

  factory MediaFormat.fromJson(Map<String, dynamic> json) {
    return MediaFormat(
      formatId: json['format_id'] ?? '',
      ext: json['ext'] ?? '',
      resolution: json['resolution'] ?? 'Audio',
      filesize: json['filesize'],
      vcodec: json['vcodec'],
      acodec: json['acodec'],
    );
  }
}
