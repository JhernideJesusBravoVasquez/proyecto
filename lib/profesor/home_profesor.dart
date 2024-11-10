import 'package:flutter/material.dart';

class HomeTeacher extends StatelessWidget {
  final String teacherName;
  final String teacherEmail;
  final String teacherId;

  HomeTeacher({
    required this.teacherName,
    required this.teacherEmail,
    required this.teacherId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Profesor'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡Bienvenido, $teacherName!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Correo: $teacherEmail'),
            Text('ID: $teacherId'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
