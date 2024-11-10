import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModificarEstudiantes extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> documentData;

  ModificarEstudiantes({required this.documentId, required this.documentData});

  @override
  _ModificarEstudiantesState createState() => _ModificarEstudiantesState();
}

class _ModificarEstudiantesState extends State<ModificarEstudiantes> {
  late TextEditingController _nombreController;
  late TextEditingController _primerApellidoController;
  late TextEditingController _segundoApellidoController;
  late TextEditingController _matriculaController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  bool _isUpdating = false; // Controla el indicador de progreso

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.documentData['nombre']);
    _primerApellidoController = TextEditingController(text: widget.documentData['primerApellido']);
    _segundoApellidoController = TextEditingController(text: widget.documentData['segundoApellido']);
    _matriculaController = TextEditingController(text: widget.documentData['matricula']);
    _correoController = TextEditingController(text: widget.documentData['correo']);
    _telefonoController = TextEditingController(text: widget.documentData['telefono']);
  }

  // Función para validar el formato del correo
  bool _isValidEmail(String email) {
    String pattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> updateDocument() async {
    // Validar que los campos no estén vacíos
    if (_nombreController.text.isEmpty ||
        _primerApellidoController.text.isEmpty ||
        _segundoApellidoController.text.isEmpty ||
        _matriculaController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    // Validar el formato del correo
    if (!_isValidEmail(_correoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formato de correo no válido')),
      );
      return;
    }

    setState(() {
      _isUpdating = true; // Muestra el indicador de progreso
    });

    try {
      await FirebaseFirestore.instance
          .collection('students') // Cambia según la colección correspondiente
          .doc(widget.documentId)
          .update({
        'nombre': _nombreController.text,
        'primerApellido': _primerApellidoController.text,
        'segundoApellido': _segundoApellidoController.text,
        'matricula': _matriculaController.text,
        'correo': _correoController.text,
        'telefono': _telefonoController.text,
      });

      setState(() {
        _isUpdating = false; // Oculta el indicador de progreso
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documento actualizado exitosamente')),
      );
    } catch (e) {
      setState(() {
        _isUpdating = false; // Oculta el indicador de progreso
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el documento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Documento de Estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _primerApellidoController,
              decoration: InputDecoration(labelText: 'Primer Apellido'),
            ),
            TextField(
              controller: _segundoApellidoController,
              decoration: InputDecoration(labelText: 'Segundo Apellido'),
            ),
            TextField(
              controller: _matriculaController,
              decoration: InputDecoration(labelText: 'Matrícula'),
            ),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            SizedBox(height: 16),
            _isUpdating
                ? CircularProgressIndicator() // Mostrar mientras se actualiza
                : ElevatedButton(
                    onPressed: updateDocument,
                    child: Text('Guardar Cambios'),
                  ),
          ],
        ),
      ),
    );
  }
}
