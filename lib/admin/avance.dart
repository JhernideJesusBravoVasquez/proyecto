import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Avance extends StatefulWidget {
  @override
  _VerActividadesEstudianteState createState() => _VerActividadesEstudianteState();
}

class _VerActividadesEstudianteState extends State<Avance> {
  final TextEditingController _matriculaController = TextEditingController();
  List<Map<String, dynamic>> _actividadesParticipadas = [];
  List<Map<String, dynamic>> _actividadesFiltradas = [];
  String _mensaje = '';
  String _categoriaSeleccionada = 'Todas';
  int _progresoTotal = 0;
  int _progresoCategoria = 0;
  bool _isLoading = false; // Nuevo indicador de carga

  static const int LIMITE_TOTAL = 60;
  static const int LIMITE_CATEGORIA = 20;

  String _formatearFechaHora(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    DateTime dateTime = timestamp.toDate();
    String formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    String amPm = dateTime.hour >= 12 ? 'PM' : 'AM';
    int hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    String formattedTime = '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
    return '$formattedDate - $formattedTime';
  }

  Future<void> buscarActividades() async {
    String matricula = _matriculaController.text.trim();

    if (matricula.isEmpty) {
      setState(() {
        _mensaje = 'Por favor, ingresa la matrícula del estudiante.';
        _actividadesParticipadas = [];
        _actividadesFiltradas = [];
        _progresoTotal = 0;
        _progresoCategoria = 0;
      });
      return;
    }

    setState(() {
      _isLoading = true; // Activar el indicador de carga
      _mensaje = ''; // Limpiar mensaje
    });

    try {
      QuerySnapshot participacionesSnapshot = await FirebaseFirestore.instance
          .collection('participaciones')
          .where('matricula', isEqualTo: matricula)
          .get();

      if (participacionesSnapshot.docs.isEmpty) {
        setState(() {
          _mensaje = 'No se encontraron actividades para la matrícula ingresada.';
          _actividadesParticipadas = [];
          _actividadesFiltradas = [];
          _progresoTotal = 0;
          _progresoCategoria = 0;
        });
      } else {
        List<Map<String, dynamic>> actividades = [];
        for (var doc in participacionesSnapshot.docs) {
          String actividadId = doc['actividadId'];
          DocumentSnapshot actividadSnapshot = await FirebaseFirestore.instance
              .collection('activities')
              .doc(actividadId)
              .get();

          if (actividadSnapshot.exists) {
            actividades.add(actividadSnapshot.data() as Map<String, dynamic>);
          }
        }

        setState(() {
          _actividadesParticipadas = actividades;
          _aplicarFiltro();
          _mensaje = actividades.isEmpty
              ? 'No se encontraron actividades para la matrícula ingresada.'
              : '';
        });
      }
    } catch (e) {
      setState(() {
        _mensaje = 'Error al buscar las actividades: $e';
        _actividadesParticipadas = [];
        _actividadesFiltradas = [];
        _progresoTotal = 0;
        _progresoCategoria = 0;
      });
    } finally {
      setState(() {
        _isLoading = false; // Desactivar el indicador de carga
      });
    }
  }

  void _aplicarFiltro() {
    if (_categoriaSeleccionada == 'Todas') {
      _actividadesFiltradas = _actividadesParticipadas;
    } else {
      _actividadesFiltradas = _actividadesParticipadas
          .where((actividad) => actividad['categoria'] == _categoriaSeleccionada.toLowerCase())
          .toList();
    }

    int sumaValoresTotal = _actividadesParticipadas.fold(
      0,
      (sum, actividad) => sum + (actividad['valor'] as int? ?? 0),
    );

    int sumaValoresCategoria = _actividadesFiltradas.fold(
      0,
      (sum, actividad) => sum + (actividad['valor'] as int? ?? 0),
    );

    String mensajeAdvertencia = '';
    if (sumaValoresTotal >= LIMITE_TOTAL) {
      mensajeAdvertencia = '¡Se ha alcanzado el límite total de 60 horas!';
    } else if (sumaValoresCategoria >= LIMITE_CATEGORIA) {
      mensajeAdvertencia =
          '¡Se ha alcanzado el límite de 20 horas en la categoría $_categoriaSeleccionada!';
    }

    setState(() {
      _mensaje = _actividadesFiltradas.isEmpty
          ? 'No se encontraron actividades en la categoría seleccionada.'
          : mensajeAdvertencia;
      _progresoTotal = sumaValoresTotal;
      _progresoCategoria = sumaValoresCategoria;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actividades del Estudiante'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _matriculaController,
              decoration: InputDecoration(
                labelText: 'Matrícula del Estudiante',
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: buscarActividades,
              child: Text('Buscar Actividades'),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Progreso Total: $_progresoTotal / $LIMITE_TOTAL horas',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (_categoriaSeleccionada != 'Todas')
                    Text(
                      'Progreso en $_categoriaSeleccionada: $_progresoCategoria / $LIMITE_CATEGORIA horas',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _categoriaSeleccionada,
              onChanged: (String? nuevaCategoria) {
                setState(() {
                  _categoriaSeleccionada = nuevaCategoria!;
                  _aplicarFiltro();
                });
              },
              items: ['Todas', 'Cultural', 'Academica', 'Deportiva']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(
                    child: Text(
                      'Cargando...',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  )
                : _actividadesFiltradas.isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _actividadesFiltradas.length,
                          itemBuilder: (context, index) {
                            var actividad = _actividadesFiltradas[index];
                            return Card(
                              elevation: 3,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nombre: ${actividad['nombre'] ?? 'N/A'}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Fecha y Hora: ${_formatearFechaHora(actividad['fechaHora'])}',
                                    ),
                                    Text(
                                      'Categoría: ${actividad['categoria'] ?? 'N/A'}',
                                    ),
                                    Text(
                                      'Valor: ${actividad['valor'] ?? 'N/A'} horas',
                                    ),
                                    Text(
                                      'Lugar: ${actividad['lugar'] ?? 'N/A'}',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          _mensaje.isNotEmpty ? _mensaje : '',
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
