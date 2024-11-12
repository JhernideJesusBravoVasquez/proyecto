import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:residencia/profesor/login_profesor.dart';
import 'perfil_profesor.dart'; // Página de perfil del profesor
import 'package:residencia/generales/actividades.dart';
import '../../generales/seleccionar_actividad.dart';
import '../../generales/actividades.dart';

class HomeProfesor extends StatelessWidget {
  final String teacherName;
  final String teacherId;
  final String teacherFirstLastname;
  final String teacherSecondLastname;
  final String teacherEmail;
  final String teacherPhone;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomeProfesor({
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
        title: Text('Bienvenido Profesor'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡Bienvenido!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Botón de Perfil
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilProfesor(
                      teacherName: teacherName,
                      teacherId: teacherId,
                      teacherFirstLastname: teacherFirstLastname,
                      teacherSecondLastname: teacherSecondLastname,
                      teacherEmail: teacherEmail,
                      teacherPhone: teacherPhone,
                    ),
                  ),
                );
              },
              child: Text('Perfil'),
            ),
            SizedBox(height: 16),

            // Botón de Actividades
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Actividades()),
                );
              },
              child: Text('Actividades'),
            ),
            SizedBox(height: 16),

            // Botón de Registrar Participación
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SeleccionarActividad(),
                  ),
                );
              },
              child: Text('Registrar Participación'),
            ),
            SizedBox(height: 20),

            // Botón de Cerrar Sesión
            ElevatedButton(
              onPressed: () {
                _showLogoutConfirmation(context);
              },
              child: Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }

  // Método para mostrar una alerta de confirmación de cierre de sesión
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cerrar Sesión'),
          content: Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cerrar Sesión'),
              onPressed: () {
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión en Firebase
  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginProfesor()),
      (Route<dynamic> route) => false,
    );
  }
}
