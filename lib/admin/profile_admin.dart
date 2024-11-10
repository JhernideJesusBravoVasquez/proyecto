import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class ProfileAdmin extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String adminName;
  final String adminId;
  final String adminFirstLastname;
  final String adminSecondLastname;
  final String adminEmail;
  final String adminPhone;

  ProfileAdmin({
    required this.adminName,
    required this.adminId,
    required this.adminFirstLastname,
    required this.adminSecondLastname,
    required this.adminEmail,
    required this.adminPhone,
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
                'Información del Administrador',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildInfoCard('Nombre', adminName),
              SizedBox(height: 10),
              _buildInfoCard('Primer Apellido', adminFirstLastname),
              SizedBox(height: 10),
              _buildInfoCard('Segundo Apellido', adminSecondLastname),
              SizedBox(height: 10),
              _buildInfoCard('ID', adminId),
              SizedBox(height: 10),
              _buildInfoCard('Correo', adminEmail),
              SizedBox(height: 10),
              _buildInfoCard('Teléfono', adminPhone),
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
            Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
