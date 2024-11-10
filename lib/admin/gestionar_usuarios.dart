import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_student_page.dart';
import 'modificar_estudiantes.dart';
import 'modificar_personal.dart';

class GestionarUsuarios extends StatefulWidget {
  @override
  _GestionarUsuarios createState() => _GestionarUsuarios();
}

class _GestionarUsuarios extends State<GestionarUsuarios> {
  final TextEditingController _documentIdController = TextEditingController();
  Map<String, dynamic>? _documentData;
  String _resultado = '';
  bool _mostrarBotonVer = false;
  bool _mostrarBotonGestionar = false;
  String? _currentCollection;

  Future<void> _buscarDocumento(String collectionName) async {
    String documentId = _documentIdController.text.trim();

    if (documentId.isEmpty) {
      setState(() {
        _resultado = 'Por favor, ingresa una matricula o id';
        _mostrarBotonVer = false;
        _mostrarBotonGestionar = false;
      });
      return;
    }

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (documentSnapshot.exists) {
        setState(() {
          _documentData = documentSnapshot.data() as Map<String, dynamic>;
          _resultado = 'Documento encontrado en $collectionName';
          _mostrarBotonVer = collectionName == 'students';
          _mostrarBotonGestionar = collectionName == 'teacher';
          _currentCollection = collectionName;
        });
      } else {
        setState(() {
          _resultado = 'No se encontró el documento en $collectionName.';
          _mostrarBotonVer = false;
          _mostrarBotonGestionar = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultado = 'Error al buscar el documento: $e';
        _mostrarBotonVer = false;
        _mostrarBotonGestionar = false;
      });
    }
  }

  void _agregarNuevoEstudiante() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStudentPage(),
      ),
    );
  }

  void _modificarEstudiante() {
    if (_documentData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModificarEstudiantes(
            documentId: _documentIdController.text.trim(),
            documentData: _documentData!,
          ),
        ),
      );
    }
  }

  void _modificarProfesor() {
    if (_documentData != null && _currentCollection != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModificarPersonal(
            documentId: _documentIdController.text.trim(),
            documentData: _documentData!,
            collectionName: _currentCollection!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestionar Usuarios'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _documentIdController,
              decoration: InputDecoration(labelText: 'Matrícula del Estudiante'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _buscarDocumento('students'),
                  child: Text('Buscar Estudiante'),
                ),
                ElevatedButton(
                  onPressed: () => _buscarDocumento('teacher'),
                  child: Text('Buscar Profesor'), // Cambiado a "Buscar Profesor"
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              _resultado,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_documentData != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nombre: ${_documentData!['nombre'] ?? 'N/A'}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (_currentCollection == 'students')
                        Text('Matrícula: ${_documentData!['matricula'] ?? 'N/A'}'),
                      if (_currentCollection == 'teacher')
                        Text('ID: ${_documentData!['id'] ?? 'N/A'}'),
                      Text('Correo: ${_documentData!['correo'] ?? 'N/A'}'),
                      Text('Teléfono: ${_documentData!['telefono'] ?? 'N/A'}'),
                      if (_mostrarBotonVer)
                        ElevatedButton(
                          onPressed: _modificarEstudiante,
                          child: Text('Ver Estudiante'),
                        ),
                      if (_mostrarBotonGestionar)
                        ElevatedButton(
                          onPressed: _modificarProfesor,
                          child: Text('Gestionar Profesor'),
                        ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _agregarNuevoEstudiante,
              child: Text('Agregar Nuevo Estudiante'),
            ),
          ],
        ),
      ),
    );
  }
}
