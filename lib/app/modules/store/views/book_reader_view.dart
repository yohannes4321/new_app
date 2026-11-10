import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/pdf_viewer.dart';

class BookReaderView extends StatelessWidget {
  const BookReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;
    
    // Robust parsing: handle if controller passes just a String or a Map
    final String? signedUrl = args is String
        ? args
        : (args is Map<String, dynamic> ? args['signedUrl'] as String? : null);
    final String? localPath = args is Map<String, dynamic>
        ? args['localPath'] as String?
        : null;

    if ((signedUrl == null || signedUrl.isEmpty) &&
        (localPath == null || localPath.isEmpty)) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Could not open this book. Invalid link.")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4C734D),
        title: const Text("Reading Mode", style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: buildPdfViewer(signedUrl: signedUrl, localPath: localPath),
    );
  }
}
