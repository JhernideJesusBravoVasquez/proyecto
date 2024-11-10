import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SolicitarConstancia extends StatefulWidget {
  final String studentMatricula;

  SolicitarConstancia({required this.studentMatricula});

  @override
  _SolicitarConstanciaState createState() => _SolicitarConstanciaState();
}

class _SolicitarConstanciaState extends State<SolicitarConstancia> {
  static const int LIMITE_TOTAL = 60; // Límite total para solicitar constancia
  int _progresoTotal = 0; // Progreso actual del estudiante
  bool _puedeSolicitar = false; // Indica si el estudiante puede solicitar constancia
  String _mensaje = '';

  @override
  void initState() {
    super.initState();
    _verificarProgresoTotal();
  }

  // Función para verificar el progreso total del estudiante
  Future<void> _verificarProgresoTotal() async {
    try {
      QuerySnapshot participacionesSnapshot = await FirebaseFirestore.instance
          .collection('participaciones')
          .where('matricula', isEqualTo: widget.studentMatricula)
          .get();

      if (participacionesSnapshot.docs.isEmpty) {
        setState(() {
          _mensaje = 'No has participado en ninguna actividad.';
          _progresoTotal = 0;
          _puedeSolicitar = false;
        });
      } else {
        // Calcular el progreso total sumando los valores de todas las actividades
        int sumaValores = 0;

        for (var doc in participacionesSnapshot.docs) {
          String actividadId = doc['actividadId'];

          DocumentSnapshot actividadSnapshot = await FirebaseFirestore.instance
              .collection('activities')
              .doc(actividadId)
              .get();

          if (actividadSnapshot.exists) {
            int valor = actividadSnapshot['valor'] ?? 0;
            sumaValores += valor;
          }
        }

        setState(() {
          _progresoTotal = sumaValores;
          _puedeSolicitar = sumaValores >= LIMITE_TOTAL;
          _mensaje = _puedeSolicitar
              ? '¡Puedes solicitar tu constancia!'
              : 'Necesitas completar $LIMITE_TOTAL horas para solicitar la constancia.';
        });

        // Verifica si ya existe una solicitud de constancia para este estudiante
        DocumentSnapshot solicitudExistente = await FirebaseFirestore.instance
            .collection('solicitudes_constancia')
            .doc(widget.studentMatricula)
            .get();

        if (solicitudExistente.exists) {
          setState(() {
            _mensaje = 'Ya has solicitado una constancia.';
            _puedeSolicitar = false; // Deshabilita la opción de solicitar
          });
        }
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al verificar el progreso: $e';
      });
    }
  }

  // Función para solicitar la constancia
  Future<void> _solicitarConstancia() async {
    try {
      // Guardar la solicitud en la colección 'solicitudes_constancia' con la matrícula como ID
      await FirebaseFirestore.instance
          .collection('solicitudes_constancia')
          .doc(widget.studentMatricula)
          .set({
        'matricula': widget.studentMatricula,
        'fechaSolicitud': Timestamp.now(),
        'estado': 'pendiente', // Estado inicial de la solicitud
      });

      setState(() {
        _mensaje = 'Solicitud de constancia enviada exitosamente.';
        _puedeSolicitar = false; // Deshabilitar la opción después de solicitar
      });
    } catch (e) {
      setState(() {
        _mensaje = 'Error al enviar la solicitud: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitar Constancia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mostrar el progreso total
            Text(
              'Progreso Total: $_progresoTotal / $LIMITE_TOTAL horas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Mensaje sobre la solicitud
            Text(
              _mensaje,
              style: TextStyle(
                fontSize: 16,
                color: _puedeSolicitar ? Colors.green : Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Botón para solicitar la constancia
            if (_puedeSolicitar)
              ElevatedButton(
                onPressed: _solicitarConstancia,
                child: Text('Solicitar Constancia'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
