import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';

class ImportarEstudiantes extends StatefulWidget {
  @override
  _ImportarEstudiantes createState() => _ImportarEstudiantes();
}

class _ImportarEstudiantes extends State<ImportarEstudiantes> {
  String _statusMessage = ''; // Mensaje de estado para el usuario

  Future<void> _importarEstudiantesDeCsv() async {
    try {
      // Seleccionar el archivo CSV
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes != null) {
          // Leer el archivo CSV y asegurar la correcta codificación UTF-8
          final csvContent = utf8.decode(fileBytes);
          List<String> rows = csvContent.split('\n');
          StringBuffer errorMessages = StringBuffer();
          bool allImportsSuccessful = true;

          // Iterar por cada línea, excluyendo la primera si es encabezado
          for (int i = 1; i < rows.length; i++) {
            if (rows[i].trim().isEmpty) continue; // Ignorar líneas vacías
            List<String> row = rows[i].split(',');

            if (row.length < 7 || row.any((field) => field.trim().isEmpty)) {
              errorMessages.writeln("Error en la fila de matrícula ${row[0].trim()}: campos vacíos.");
              allImportsSuccessful = false;
              continue;
            }

            String matricula = row[0].trim();
            String nombre = row[1].trim();
            String primerApellido = row[2].trim();
            String segundoApellido = row[3].trim();
            String correo = row[4].trim();
            String telefono = row[5].trim();
            String carrera = row[6].trim();

            // Verificar si el estudiante ya existe en Firebase
            var estudianteDoc = await FirebaseFirestore.instance.collection('students').doc(matricula).get();
            if (!estudianteDoc.exists) {
              // Agregar a Firestore y Firebase Authentication
              await FirebaseFirestore.instance.collection('students').doc(matricula).set({
                'nombre': nombre,
                'primerApellido': primerApellido,
                'segundoApellido': segundoApellido,
                'correo': correo,
                'matricula': matricula,
                'telefono': telefono,
                'carrera': carrera,
              });

              // Registrar en Firebase Authentication
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: correo,
                  password: matricula,
                );
              } on FirebaseAuthException catch (e) {
                errorMessages.writeln("Error al crear usuario para matrícula $matricula: ${e.message}");
                allImportsSuccessful = false;
              }
            } else {
              errorMessages.writeln("La matrícula $matricula ya está registrada en la base de datos.");
              allImportsSuccessful = false;
            }
          }

          // Mostrar mensaje de éxito o de error
          setState(() {
            _statusMessage = allImportsSuccessful
                ? 'Estudiantes importados exitosamente.'
                : 'Algunos estudiantes no se pudieron importar:\n$errorMessages';
          });
        }
      } else {
        setState(() {
          _statusMessage = 'No se seleccionó ningún archivo.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al importar estudiantes: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Importar Estudiantes desde CSV'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _statusMessage.contains('Error') ? Colors.red : Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _importarEstudiantesDeCsv,
              child: Text('Seleccionar archivo CSV e importar'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
