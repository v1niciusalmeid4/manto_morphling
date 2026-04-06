import 'dart:io';

import 'package:html_to_pdf/html_to_pdf.dart';
import 'package:morphling/src/services/file_service/interface/file_service.dart';
import 'package:path_provider/path_provider.dart';

class FileServiceImpl implements FileService {
  @override
  @override
  Future<File> transformHtmlToPdf({
    required String html,
    required String targetName,
  }) async {
    final targetPath = await getApplicationDocumentsDirectory();

    final uniqueName = '${targetName}_${DateTime.now().millisecondsSinceEpoch}';

    return HtmlToPdf.convertFromHtmlContent(
      htmlContent: html,
      printPdfConfiguration: PrintPdfConfiguration(
        targetDirectory: targetPath.path,
        targetName: uniqueName,
        printSize: PrintSize.A4,
        printOrientation: PrintOrientation.Portrait,
      ),
    );
  }
}
