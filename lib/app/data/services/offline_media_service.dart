import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Stores only server-authorized, user-specific media in the app sandbox.
/// The backend remains the source of truth for entitlement checks.
class OfflineMediaService {
  final Dio _dio = Dio();

  Future<String> download({
    required String url,
    required String id,
    required String extension,
    void Function(double progress)? onProgress,
  }) async {
    if (url.trim().isEmpty) throw Exception('Media URL is unavailable.');

    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/offline_media');
    await directory.create(recursive: true);
    final path = '${directory.path}/$id.$extension';

    await _dio.download(
      url,
      path,
      deleteOnError: true,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress?.call(received / total);
      },
    );
    return path;
  }

  Future<bool> exists(String id, String extension) async {
    final root = await getApplicationDocumentsDirectory();
    return File('${root.path}/offline_media/$id.$extension').exists();
  }
}
