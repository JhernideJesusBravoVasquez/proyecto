// importar de acuerdo a la plataforma
import 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_io.dart'
    if (dart.library.html) 'file_saver_web.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;

class Participaciones extends StatefulWidget {
  final String actividadId;

  Participaciones({required this.actividadId});

  @override
  _VerParticipantesActividadState createState() => _VerParticipantesActividadState();
}

class _VerParticipantesActividadState extends State<Participaciones> {
  late Future<List<Map<String, dynamic>>> _participantesFuture;

  @override
  void initState() {
    super.initState();
    _participantesFuture = _obtenerParticipantes();
  }

  Future<List<Map<String, dynamic>>> _obtenerParticipantes() async {
    try {
      QuerySnapshot participacionesSnapshot = await FirebaseFirestore.instance
          .collection('participaciones')
          .where('actividadId', isEqualTo: widget.actividadId)
          .get();

      List<Map<String, dynamic>> participantes = [];

      for (var doc in participacionesSnapshot.docs) {
        String matricula = doc['matricula'];
        DocumentSnapshot estudianteSnapshot = await FirebaseFirestore.instance
            .collection('students')
            .doc(matricula)
            .get();

        if (estudianteSnapshot.exists) {
          Map<String, dynamic> estudianteData = estudianteSnapshot.data() as Map<String, dynamic>;
          participantes.add(estudianteData);
        }
      }
      return participantes;
    } catch (e) {
      print('Error al obtener participantes: $e');
      return [];
    }
  }

  Future<void> _exportarPdf(List<Map<String, dynamic>> participantes) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PARTICIPANTES EN LA ACTIVIDAD', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: ['Matricula', 'Nombre', 'Primer Apellido', 'Segundo Apellido'],
                  data: participantes.map((estudiante) {
                    return [
                      estudiante['matricula'] ?? '',
                      estudiante['nombre'] ?? '',
                      estudiante['primerApellido'] ?? '',
                      estudiante['segundoApellido'] ?? '',
                    ];
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
    await guardarPdf(pdf, 'Participantes_${widget.actividadId}.pdf');
  }

  Future<void> _exportarCsv(List<Map<String, dynamic>> participantes) async {
    String csvData = 'Matrícula,Nombre,Primer Apellido,Segundo Apellido\n';
    for (var estudiante in participantes) {
      csvData += '${estudiante['matricula'] ?? ''},${estudiante['nombre'] ?? ''},${estudiante['primerApellido'] ?? ''},${estudiante['segundoApellido'] ?? ''}\n';
    }
    await guardarCsv(csvData, 'Participantes_${widget.actividadId}.csv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes en la Actividad'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            onPressed: () async {
              List<Map<String, dynamic>> participantes = await _participantesFuture;
              if (participantes.isNotEmpty) {
                await _exportarPdf(participantes);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              List<Map<String, dynamic>> participantes = await _participantesFuture;
              if (participantes.isNotEmpty) {
                await _exportarCsv(participantes);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _participantesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar participantes'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron participantes.'));
          } else {
            List<Map<String, dynamic>> participantes = snapshot.data!;
            return ListView.builder(
              itemCount: participantes.length,
              itemBuilder: (context, index) {
                var estudiante = participantes[index];
                return Card(
                  child: ListTile(
                    title: Text('${estudiante['nombre']} ${estudiante['primerApellido']} ${estudiante['segundoApellido']}'),
                    subtitle: Text('Matrícula: ${estudiante['matricula']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
