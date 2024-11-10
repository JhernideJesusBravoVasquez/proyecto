import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registrar_participacion.dart';

class SeleccionarActividad extends StatefulWidget {
  @override
  _SeleccionarActividadState createState() => _SeleccionarActividadState();
}

class _SeleccionarActividadState extends State<SeleccionarActividad> {

  String _formatearFechaHora(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String formattedTime = '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
    return '$formattedDate - $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades Activas'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('activities')
            .where('estado', isEqualTo: 'activo')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No hay actividades activas.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> actividad = doc.data() as Map<String, dynamic>;
              String actividadId = doc.id;

              return Card(
                child: ListTile(
                  title: Text('Actividad: ${actividad['nombre']}'),
                  subtitle: Text('Fecha y Hora: ${_formatearFechaHora(actividad['fechaHora'])}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrarParticipacion(actividadId: actividadId),
                        ),
                      );
                    },
                    child: Text('Registrar'),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
