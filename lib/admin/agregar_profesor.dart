import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgregarProfesor extends StatefulWidget {
  @override
  _AddTeacherPageState createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AgregarProfesor> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstLastController = TextEditingController();
  final TextEditingController _secondLastController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _addTeacher() async {
    try {
      String id = _idController.text.trim();
      String email = _emailController.text.trim();
      String telefono = _phoneController.text.trim();

      if (id.isEmpty || email.isEmpty || telefono.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El ID, correo y teléfono son obligatorios')),
        );
        return;
      }

      // Verificar si el profesor ya existe en Firestore
      var teacherDoc = await FirebaseFirestore.instance.collection('teacher').doc(id).get();

      if (teacherDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El ID ya está registrado')),
        );
      } else {
        // Registrar al profesor en Firestore
        await FirebaseFirestore.instance.collection('teacher').doc(id).set({
          'nombre': _nameController.text,
          'primerApellido': _firstLastController.text,
          'segundoApellido': _secondLastController.text,
          'correo': email,
          'id': id,
          'telefono': telefono,
        });

        // Crear el usuario en Firebase Authentication
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: id, // Usar ID como contraseña
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profesor agregado exitosamente')),
          );
        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear cuenta: ${e.message}')),
          );
        }
      }

      // Limpiar los campos
      _nameController.clear();
      _firstLastController.clear();
      _secondLastController.clear();
      _emailController.clear();
      _idController.clear();
      _phoneController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar profesor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Profesor'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID (Usado como contraseña)'),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _firstLastController,
              decoration: InputDecoration(labelText: 'Primer Apellido'),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _secondLastController,
              decoration: InputDecoration(labelText: 'Segundo Apellido'),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            SizedBox(height: size.height * 0.02),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: _addTeacher,
                child: Text('Guardar Profesor'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
