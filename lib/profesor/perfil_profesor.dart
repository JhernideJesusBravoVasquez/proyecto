import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PerfilProfesor extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String teacherName;
  final String teacherId;
  final String teacherFirstLastname;
  final String teacherSecondLastname;
  final String teacherEmail;
  final String teacherPhone;

  PerfilProfesor({
    required this.teacherName,
    required this.teacherId,
    required this.teacherFirstLastname,
    required this.teacherSecondLastname,
    required this.teacherEmail,
    required this.teacherPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Información del Profesor',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildInfoCard('Nombre', teacherName),
              SizedBox(height: 10),
              _buildInfoCard('Primer Apellido', teacherFirstLastname),
              SizedBox(height: 10),
              _buildInfoCard('Segundo Apellido', teacherSecondLastname),
              SizedBox(height: 10),
              _buildInfoCard('ID', teacherId),
              SizedBox(height: 10),
              _buildInfoCard('Correo', teacherEmail),
              SizedBox(height: 10),
              _buildInfoCard('Teléfono', teacherPhone),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
