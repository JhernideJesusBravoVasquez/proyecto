import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Importa Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart';  // Importa Cloud Firestore
import 'home_admin.dart';  // Importa la página de bienvenida
import '../main.dart';  // Importa la página principal

class LoginAdmin extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginAdmin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;  // Instancia de Firebase Auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;  // Instancia de Firestore

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;  // Indicador para mostrar mientras se realiza la autenticación

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Login Administrativo'),
        automaticallyImplyLeading: true,  // Habilita el botón de retroceso
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Redirige al HomePage al presionar el botón "Back"
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
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: size.height * 0.04),
            _isLoading
                ? CircularProgressIndicator()  // Muestra indicador de carga durante el login
                : SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _loginWithEmailAndPassword,
                      child: Text('Iniciar Sesión'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Método para realizar login con Firebase usando correo e id
  void _loginWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;  // Muestra el indicador de carga
    });

    try {
      String email = _emailController.text;
      String id = _passwordController.text;

      // Verifica si el admin existe en Firestore
      var adminDoc = await _firestore.collection('admin').doc(id).get();

      if (adminDoc.exists && adminDoc.data()?['correo'] == email) {
        // Si el admin existe y el correo coincide, obtener el nombre
        String adminId = adminDoc.data()?['id'];
        String adminName = adminDoc.data()?['nombre'];
        String adminFirstLastname = adminDoc.data()?['primerApellido'];
        String adminSecondLastname = adminDoc.data()?['segundoApellido'];
        String adminEmail = adminDoc.data()?['correo'];
        String adminPhone = adminDoc.data()?['telefono'];

        // Iniciar sesión con Firebase
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: id,  // Usa el id como contraseña
        );

        // Si el login es exitoso, navega a la página de bienvenida para admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (
              context) => HomeAdmin(
                adminName: adminName, 
                adminId: adminId, 
                adminFirstLastname: adminFirstLastname, 
                adminSecondLastname: adminSecondLastname, 
                adminEmail: adminEmail, 
                adminPhone: adminPhone
                ),
              ),  // Pasa el nombre al constructor
        );
      } else {
        setState(() {
          _isLoading=false;
        });
        // Muestra mensaje de error si el admin no existe o el correo no coincide
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de autenticación'),
              content: Text('Correo o id incorrectos.'),
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
        _isLoading = false;  // Detiene el indicador de carga
      });

      // Muestra mensaje de error si la autenticación falla
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