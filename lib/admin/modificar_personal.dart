import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModificarPersonal extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> documentData;
  String collectionName='tacher';

  // Solo se permite la modificación de la colección 'teacher'
  ModificarPersonal({required this.documentId, required this.documentData, required this.collectionName});

  @override
  _ModificarPersonalState createState() => _ModificarPersonalState();
}

class _ModificarPersonalState extends State<ModificarPersonal> {
  late TextEditingController _nombreController;
  late TextEditingController _primerApellidoController;
  late TextEditingController _segundoApellidoController;
  late TextEditingController _idController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.documentData['nombre']);
    _primerApellidoController = TextEditingController(text: widget.documentData['primerApellido']);
    _segundoApellidoController = TextEditingController(text: widget.documentData['segundoApellido']);
    _idController = TextEditingController(text: widget.documentData['id']);
    _correoController = TextEditingController(text: widget.documentData['correo']);
    _telefonoController = TextEditingController(text: widget.documentData['telefono']);
  }

  // Validar formato de correo electrónico
  bool _isValidEmail(String email) {
    String pattern = r'^[^@]+@[^@]+\.[^@]+$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  // Validar formato de teléfono (solo dígitos y longitud de 10)
  bool _isValidPhoneNumber(String phone) {
    String pattern = r'^\d{10}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(phone);
  }

  Future<void> updateDocument() async {
    // Validar que los campos no estén vacíos
    if (_nombreController.text.isEmpty ||
        _primerApellidoController.text.isEmpty ||
        _segundoApellidoController.text.isEmpty ||
        _idController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _telefonoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    // Validar formato de correo electrónico
    if (!_isValidEmail(_correoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formato de correo no válido')),
      );
      return;
    }

    // Validar formato de teléfono
    if (!_isValidPhoneNumber(_telefonoController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El número de teléfono debe tener 10 dígitos')),
      );
      return;
    }

    setState(() {
      _isUpdating = true; // Muestra el indicador de progreso
    });

    try {
      // Actualiza solo en la colección 'teacher'
      await FirebaseFirestore.instance
          .collection('teacher')
          .doc(widget.documentId)
          .update({
        'nombre': _nombreController.text,
        'primerApellido': _primerApellidoController.text,
        'segundoApellido': _segundoApellidoController.text,
        'id': _idController.text,
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
        title: Text('Modificar Información del Profesor'),
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
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID'),
            ),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(labelText: 'Correo'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.number,
              maxLength: 10, // Limita el número de dígitos a 10
            ),
            SizedBox(height: 16),
            _isUpdating
                ? CircularProgressIndicator()
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
