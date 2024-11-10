import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class RegistrarParticipacion extends StatefulWidget {
  final String actividadId;

  RegistrarParticipacion({required this.actividadId});

  @override
  _RegistrarParticipacionState createState() => _RegistrarParticipacionState();
}

class _RegistrarParticipacionState extends State<RegistrarParticipacion> {
  bool _participacionRegistrada = false;
  String _mensaje = '';

  // Método para escanear el código QR
  Future<void> escanearQR() async {
    try {
      String qrResultado = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color de la línea del escáner
        'Cancelar', // Texto del botón de cancelar
        true, // Permitir cambio de cámara
        ScanMode.QR, // Modo de escaneo QR
      );

      // Si el resultado del escaneo es válido
      if (qrResultado != '-1') {
        _registrarParticipacion(qrResultado);
      } else {
        setState(() {
          _mensaje = 'Escaneo cancelado o no válido.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al escanear el código QR: $e';
      });
    }
  }

  // Método para registrar la participación
  Future<void> _registrarParticipacion(String matricula) async {
    String actividadId = widget.actividadId;

    try {
      // Verificar si la matrícula del estudiante existe
      DocumentSnapshot estudianteSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(matricula)
          .get();

      if (!estudianteSnapshot.exists) {
        setState(() {
          _mensaje = 'La matrícula del estudiante no existe.';
        });
        return;
      }

      // Verificar si ya existe una participación para la misma actividad
      QuerySnapshot participacionExistente = await FirebaseFirestore.instance
          .collection('participaciones')
          .where('matricula', isEqualTo: matricula)
          .where('actividadId', isEqualTo: actividadId)
          .get();

      if (participacionExistente.docs.isNotEmpty) {
        setState(() {
          _mensaje = 'El estudiante ya está registrado en esta actividad.';
        });
        return;
      }

      // Registrar la participación si no existe previamente
      await FirebaseFirestore.instance.collection('participaciones').add({
        'matricula': matricula,
        'actividadId': actividadId,
        'fechaRegistro': Timestamp.now(),
      });

      setState(() {
        _participacionRegistrada = true;
        _mensaje = 'Participación registrada exitosamente.';
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al registrar la participación: $e';
      });
    }
  }

  // Método para importar matrículas desde un archivo CSV
  Future<void> _importarMatriculasDesdeCsv() async {
    try {
      // Seleccionar el archivo CSV
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes != null) {
          // Leer el archivo CSV y convertirlo en una lista de líneas
          final csvContent = utf8.decode(fileBytes);
          List<String> rows = csvContent.split('\n');

          for (int i = 1; i < rows.length; i++) {
            if (rows[i].trim().isEmpty) continue; // Ignorar líneas vacías
            List<String> row = rows[i].split(',');

            if (row.isNotEmpty) {
              String matricula = row[0].trim();

              // Verificar si la participación ya existe en Firebase
              var participacionDoc = await FirebaseFirestore.instance
                  .collection('participaciones')
                  .where('matricula', isEqualTo: matricula)
                  .where('actividadId', isEqualTo: widget.actividadId)
                  .get();

              if (participacionDoc.docs.isEmpty) {
                // Agregar a Firebase si no existe
                await FirebaseFirestore.instance.collection('participaciones').add({
                  'matricula': matricula,
                  'actividadId': widget.actividadId,
                  'fechaRegistro': Timestamp.now(),
                });
              }
            }
          }

          setState(() {
            _mensaje = 'Matrículas importadas exitosamente.';
          });
        }
      } else {
        setState(() {
          _mensaje = 'No se seleccionó ningún archivo.';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al importar matrículas: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Participación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID de la Actividad: ${widget.actividadId}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: escanearQR,
              child: Text('Escanear Código QR'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _importarMatriculasDesdeCsv,
              child: Text('Importar matrículas desde CSV'),
            ),
            SizedBox(height: 16),
            Text(
              _mensaje,
              style: TextStyle(
                color: _participacionRegistrada ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
