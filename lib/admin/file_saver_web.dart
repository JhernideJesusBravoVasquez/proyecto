// file_saver_web.dart
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import 'dart:convert';

Future<void> guardarPdf(pw.Document pdf, String fileName) async {
  // Genera los bytes del PDF
  final pdfBytes = await pdf.save();

  // Crea un blob en la web
  final blob = html.Blob([pdfBytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Crea un enlace para la descarga
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  // Libera el URL
  html.Url.revokeObjectUrl(url);
}

Future<void> guardarCsv(String csvData, String fileName) async {
  final bytes = utf8.encode(csvData);
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}