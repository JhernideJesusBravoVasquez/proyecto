// file_saver_stub.dart
import 'package:pdf/widgets.dart' as pw;

Future<void> guardarPdf(pw.Document pdf, String fileName) async {
  throw UnsupportedError('Guardar archivos no está soportado en esta plataforma.');
}

Future<void> guardarCsv(String csvData, String fileName) async {
  throw UnsupportedError('Guardar archivos no está soportado en esta plataforma.');
}