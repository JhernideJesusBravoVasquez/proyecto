// importar de acuerdo a la plataforma
import 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_io.dart'
    if (dart.library.html) 'file_saver_web.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;

class VerSolicitudesConstancia extends StatefulWidget {
  @override
  _VerSolicitudesConstanciaState createState() => _VerSolicitudesConstanciaState();
}

class _VerSolicitudesConstanciaState extends State<VerSolicitudesConstancia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de Constancia'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('solicitudes_constancia')
            .where('estado', isEqualTo: 'pendiente')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay solicitudes pendientes.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> solicitudData = doc.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text('Matrícula: ${solicitudData['matricula']}'),
                  subtitle: Text('Fecha de Solicitud: ${_formatearFecha(solicitudData['fechaSolicitud'])}'),
                  trailing: ElevatedButton(
                    onPressed: () => _emitirConstancia(solicitudData, doc.id),
                    child: Text('Emitir Constancia'),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatearFecha(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  Future<void> _emitirConstancia(Map<String, dynamic> solicitudData, String solicitudId) async {
    try {
      DocumentSnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(solicitudData['matricula'])
          .get();

      if (!studentSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró el estudiante.')),
        );
        return;
      }

      Map<String, dynamic> studentData = studentSnapshot.data() as Map<String, dynamic>;

      // Generar el PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CONSTANCIA DE PARTICIPACIÓN', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 20),
                  pw.Text('Nombre: ${studentData['nombre']} ${studentData['primerApellido']} ${studentData['segundoApellido']}'),
                  pw.Text('Matrícula: ${studentData['matricula']}'),
                  pw.Text('Correo: ${studentData['correo']}'),
                  pw.Text('Teléfono: ${studentData['telefono']}'),
                  pw.SizedBox(height: 20),
                  pw.Text('Esta constancia certifica que el estudiante ha cumplido con las actividades requeridas.'),
                ],
              ),
            );
          },
        ),
      );

      // Guardar el PDF usando la función condicional
      await guardarPdf(pdf, 'Constancia_${studentData['matricula']}.pdf');

      // Actualizar el estado de la solicitud a 'emitida'
      await FirebaseFirestore.instance
          .collection('solicitudes_constancia')
          .doc(solicitudId)
          .update({'estado': 'emitida'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Constancia emitida correctamente.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al emitir la constancia: $e')),
      );
    }
  }
}
