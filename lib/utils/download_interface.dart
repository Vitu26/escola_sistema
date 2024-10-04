// utils/download_interface.dart
import 'package:flutter/material.dart';

abstract class DownloadInterface {
  Future<void> downloadPdf(String url, String fileName, BuildContext context);
}
