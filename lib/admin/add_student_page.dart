import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'importar_estudiantes.dart';

class AddStudentPage extends StatefulWidget {
  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstLastController = TextEditingController();
  final TextEditingController _secondLastController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCarrera; // Para manejar la selección de la carrera

  Future<void> _addStudent() async {
    try {
      String matricula = _matriculaController.text.trim();
      String email = _emailController.text.trim();
      String telefono = _phoneController.text.trim();

      if (matricula.isEmpty || telefono.isEmpty || _selectedCarrera == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La matrícula, teléfono y carrera son obligatorios')),
        );
        return;
      }

      var studentDoc = await FirebaseFirestore.instance.collection('students').doc(matricula).get();

      if (studentDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La matrícula ya está registrada')),
        );
      } else {
        // Registrar al estudiante en Firestore
        await FirebaseFirestore.instance.collection('students').doc(matricula).set({
          'nombre': _nameController.text,
          'primerApellido': _firstLastController.text,
          'segundoApellido': _secondLastController.text,
          'correo': email,
          'matricula': matricula,
          'telefono': telefono,
          'carrera': _selectedCarrera,
        });

        // Crear el usuario en Firebase Authentication
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: matricula, // Usar matrícula como contraseña
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estudiante agregado exitosamente')),
        );

        _nameController.clear();
        _firstLastController.clear();
        _secondLastController.clear();
        _emailController.clear();
        _matriculaController.clear();
        _phoneController.clear();
        setState(() {
          _selectedCarrera = null;
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear cuenta: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar estudiante: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Estudiante'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _matriculaController,
              decoration: InputDecoration(labelText: 'Matrícula'),
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
            DropdownButton<String>(
              hint: Text("Carrera"), // Texto predeterminado
              value: _selectedCarrera,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCarrera = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'Licenciatura en Enseñanza de Idiomas',
                  child: Text('Licenciatura en Enseñanza de Idiomas'),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: _addStudent,
                child: Text('Guardar Estudiante'),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: 200,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ImportarEstudiantes()),
                  );
                },
                child: Text('Importar Estudiantes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
