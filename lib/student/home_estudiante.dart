import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'perfil_estudiante.dart'; // Página de perfil del estudiante
import 'package:residencia/generales/actividades.dart';
import 'inscribirse_actividad.dart'; // Página de inscripción en actividades
import 'avance_estudiante.dart'; // Página de avance del estudiante
import 'solicitar_constancia.dart'; // Página para solicitar constancia
import 'student_login.dart'; // Página de login de estudiante

class HomeEstudiante extends StatelessWidget {
  final String studentName;
  final String studentMatricula;
  final String studentFirstLastname;
  final String studentSecondLastname;
  final String studentEmail;
  final String studentPhone;
  final String studentCarrera;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomeEstudiante({
    required this.studentMatricula,
    required this.studentName,
    required this.studentFirstLastname,
    required this.studentSecondLastname,
    required this.studentEmail,
    required this.studentPhone,
    required this.studentCarrera,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Estudiante'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text(
              'Bienvenido!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Botón de Perfil
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (
                      context) => PerfilEstudiante(
                        studentName: studentName,
                        studentMatricula: studentMatricula,
                        studentFirstLastname: studentFirstLastname,
                        studentSecondLastname: studentSecondLastname,
                        studentEmail: studentEmail,
                        studentPhone: studentPhone,
                        studentCarrera: studentCarrera,
                      )),
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

            // Botón de Inscribirse
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InscribirseActividad(
                    studentMatricula: studentMatricula,
                  )),
                );
              },
              child: Text('Inscribirse'),
              
            ),
            SizedBox(height: 16),

            // Botón de Avance
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvanceEstudiante(
                    studentMatricula: studentMatricula,
                  )),
                );
              },
              child: Text('Avance'),
              
            ),
            SizedBox(height: 16),

            // Botón de Solicitar Constancia
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SolicitarConstancia(
                    studentMatricula: studentMatricula,
                  )),
                );
              },
              child: Text('Solicitar Constancia'),
              
            ),
            SizedBox(height: 20),

            // Botón de cerrar sesión
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
                Navigator.of(context).pop(); // Cierra el cuadro de diálogo
              },
            ),
            TextButton(
              child: Text('Cerrar Sesión'),
              onPressed: () {
                _signOut(context); // Llama al método para cerrar sesión
              },
            ),
          ],
        );
      },
    );
  }

  // Método para cerrar sesión en Firebase
  Future<void> _signOut(BuildContext context) async {
    await _auth.signOut(); // Cierra la sesión en Firebase
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => StudentLoginPage()), // Redirige al login
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }
}
