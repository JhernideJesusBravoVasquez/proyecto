// file_saver_io.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> guardarPdf(pw.Document pdf, String fileName) async {
  // Obtiene el directorio de documentos de la aplicación
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String savePath = '${appDocumentsDirectory.path}/$fileName';

  // Guarda el archivo PDF
  final file = File(savePath);
  await file.writeAsBytes(await pdf.save());

  print('Archivo guardado en $savePath');
}

Future<void> guardarCsv(String csvData, String fileName) async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
  String savePath = '${appDocumentsDirectory.path}/$fileName';
  final file = File(savePath);
  await file.writeAsString(csvData);
}