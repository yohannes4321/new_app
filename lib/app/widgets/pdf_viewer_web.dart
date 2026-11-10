import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

Widget buildPdfViewer({String? signedUrl, String? localPath}) {
  return SfPdfViewer.network(signedUrl!, enableDoubleTapZooming: true);
}
