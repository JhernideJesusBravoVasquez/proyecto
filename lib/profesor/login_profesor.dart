import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_profesor.dart';
import '../main.dart';

class LoginProfesor extends StatefulWidget {
  @override
  _TeacherLoginPageState createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<LoginProfesor> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Profesor'),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
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
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID del Profesor'),
              obscureText: true,
            ),
            SizedBox(height: size.height * 0.04),
            _isLoading
                ? CircularProgressIndicator()
                : SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loginWithEmailAndId,
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Método para realizar login con Firebase usando correo e ID
  void _loginWithEmailAndId() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String email = _emailController.text.trim();
      String id = _idController.text.trim();

      // Verifica si el profesor existe en Firestore
      var teacherDoc = await _firestore.collection('teacher').doc(id).get();

      if (teacherDoc.exists && teacherDoc.data()?['correo'] == email) {
        // Si el profesor existe y el correo coincide, obtener la información
        String teacherId = teacherDoc.data()?['id'];
        String teacherName = teacherDoc.data()?['nombre'];
        String teacherFirstLastname = teacherDoc.data()?['primerApellido'];
        String teacherSecondLastname = teacherDoc.data()?['segundoApellido'];
        String teacherEmail = teacherDoc.data()?['correo'];
        String teacherPhone = teacherDoc.data()?['telefono'];

        // Iniciar sesión con Firebase Authentication
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: id, // Usa el ID como contraseña
        );

        // Navegar a la página de bienvenida del profesor
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeProfesor(
              teacherName: teacherName,
              teacherId: teacherId,
              teacherFirstLastname: teacherFirstLastname,
              teacherSecondLastname: teacherSecondLastname,
              teacherEmail: teacherEmail,
              teacherPhone: teacherPhone,
            ),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de autenticación'),
              content: Text('Correo o ID incorrectos.'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Mostrar mensaje de error si la autenticación falla
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de autenticación'),
            content: Text(e.message ?? 'Error desconocido'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
