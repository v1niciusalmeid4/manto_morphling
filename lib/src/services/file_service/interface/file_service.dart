import 'dart:io';

abstract class FileService {
  Future<File> transformHtmlToPdf({
    required String html,
    required String targetName,
  });
}
