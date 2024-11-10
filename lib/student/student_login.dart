import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'home_estudiante.dart'; // Página de bienvenida para el estudiante
import '../main.dart'; // Página principal

class StudentLoginPage extends StatefulWidget {
  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia de Firebase Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instancia de Firestore

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  bool _isLoading = false; // Indicador para mostrar mientras se realiza la autenticación

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Estudiante'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()), // Página principal
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _matriculaController,
              decoration: InputDecoration(labelText: 'Matrícula'),
              obscureText: true,
            ),
            SizedBox(height: size.height * 0.04),
            _isLoading
                ? CircularProgressIndicator() // Muestra indicador de carga durante el login
                : SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loginWithEmailAndMatricula,
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Método para realizar login con Firebase usando correo y matrícula
  void _loginWithEmailAndMatricula() async {
    setState(() {
      _isLoading = true; // Muestra el indicador de carga
    });

    try {
      String email = _emailController.text.trim();
      String matricula = _matriculaController.text.trim();

      // Verifica si el estudiante existe en Firestore
      var studentDoc = await _firestore.collection('students').doc(matricula).get();

      if (studentDoc.exists && studentDoc.data()?['correo'] == email) {
        // Si el estudiante existe y el correo coincide, obtener la información
        String studentMatricula = studentDoc.data()?['matricula'];
        String studentName = studentDoc.data()?['nombre'];
        String studentFirstLastname = studentDoc.data()?['primerApellido'];
        String studentSecondLastname = studentDoc.data()?['segundoApellido'];
        String studentEmail = studentDoc.data()?['correo'];
        String studentPhone = studentDoc.data()?['telefono'];
        String studentCarrera = studentDoc.data()?['carrera'];

        // Iniciar sesión con Firebase
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: matricula, // Usa la matrícula como contraseña
        );

        // Navegar a la página de bienvenida del estudiante
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (
              context) => HomeEstudiante(
              studentName: studentName,
              studentMatricula: studentMatricula,
              studentFirstLastname: studentFirstLastname,
              studentSecondLastname: studentSecondLastname,
              studentEmail: studentEmail,
              studentPhone: studentPhone,
              studentCarrera: studentCarrera,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading=false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text('Error de autenticación'),
              content: Text('Correo o matricula incorrectos.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: (){
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          }
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false; //detiene el indicador de carga
      });

      //muestra mensaje de error si la autenticacion falla
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Error de autenticación'),
            content: Text(e.message ?? 'Error desconocido'),
            actions: <Widget> [
              TextButton(
                child: Text('OK'),
                onPressed: (){
                  Navigator.of(context).pop();
                }
              )
            ],
          );
        }
      );
    } 
  }
}