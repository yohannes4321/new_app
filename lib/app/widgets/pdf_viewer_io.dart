import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Widget buildPdfViewer({String? signedUrl, String? localPath}) {
  if (localPath != null && localPath.isNotEmpty) {
    return SfPdfViewer.file(File(localPath), enableDoubleTapZooming: true);
  }
  return SfPdfViewer.network(signedUrl!, enableDoubleTapZooming: true);
}
