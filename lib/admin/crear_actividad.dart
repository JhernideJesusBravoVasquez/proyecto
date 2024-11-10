import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearActividad extends StatefulWidget {
  final String adminId; // Recibe el ID del administrador

  CrearActividad({required this.adminId});

  @override
  _CrearActividadPageState createState() => _CrearActividadPageState();
}

class _CrearActividadPageState extends State<CrearActividad> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();

  String? _diaSeleccionado;
  String? _mesSeleccionado;
  String? _anioSeleccionado;
  String? _horaSeleccionada;
  String? _minutoSeleccionado;
  String? _amPmSeleccionado;
  String? _categoriaSeleccionada;
  String? _estadoSeleccionado;
  List<String> _diasDisponibles = List.generate(31, (index) => (index + 1).toString());
  List<String> _aniosDisponibles = List.generate(11, (index) => (2020 + index).toString());
  List<String> _horasDisponibles = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _minutosDisponibles = List.generate(60, (index) => (index).toString().padLeft(2, '0'));

  // Función para crear un timestamp a partir de la fecha y hora seleccionadas
  Timestamp _crearTimestamp() {
    int dia = int.parse(_diaSeleccionado!);
    int mes = int.parse(_mesSeleccionado!);
    int anio = int.parse(_anioSeleccionado!);
    int hora = int.parse(_horaSeleccionada!);
    int minuto = int.parse(_minutoSeleccionado!);

    if (_amPmSeleccionado == 'PM' && hora != 12) {
      hora += 12;
    } else if (_amPmSeleccionado == 'AM' && hora == 12) {
      hora = 0;
    }

    return Timestamp.fromDate(DateTime(anio, mes, dia, hora, minuto));
  }

  Future<void> _crearActividad() async {
    if (_nombreController.text.isEmpty ||
        _diaSeleccionado == null ||
        _mesSeleccionado == null ||
        _anioSeleccionado == null ||
        _horaSeleccionada == null ||
        _minutoSeleccionado == null ||
        _amPmSeleccionado == null ||
        _categoriaSeleccionada == null ||
        _valorController.text.isEmpty ||
        _estadoSeleccionado == null ||
        _lugarController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, rellena todos los campos')),
      );
      return;
    }

    int? valorEnHoras = int.tryParse(_valorController.text);
    if (valorEnHoras == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El valor en horas debe ser un número')),
      );
      return;
    }

    Timestamp fechaHoraTimestamp = _crearTimestamp();
    String idActividad = '${_diaSeleccionado!.padLeft(2, '0')}${_mesSeleccionado!.padLeft(2, '0')}${_anioSeleccionado!}';

    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('activities')
          .doc(idActividad)
          .get();

      if (docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ya existe una actividad con esta fecha')),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('activities').doc(idActividad).set({
        'nombre': _nombreController.text,
        'fechaHora': fechaHoraTimestamp,
        'categoria': _categoriaSeleccionada,
        'valor': valorEnHoras,
        'estado': _estadoSeleccionado,
        'lugar': _lugarController.text,
        'id': idActividad,
        'adminId': widget.adminId, // Guarda el ID del admin que crea la actividad
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Actividad creada exitosamente')),
      );

      // Limpiar los campos después de crear la actividad
      _nombreController.clear();
      _valorController.clear();
      _lugarController.clear();
      setState(() {
        _diaSeleccionado = null;
        _mesSeleccionado = null;
        _anioSeleccionado = null;
        _horaSeleccionada = null;
        _minutoSeleccionado = null;
        _amPmSeleccionado = null;
        _categoriaSeleccionada = null;
        _estadoSeleccionado = null;
        _diasDisponibles = List.generate(31, (index) => (index + 1).toString());
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear la actividad: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Actividad'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Día'),
                      value: _diaSeleccionado,
                      onChanged: (String? nuevoDia) {
                        setState(() {
                          _diaSeleccionado = nuevoDia;
                        });
                      },
                      items: _diasDisponibles
                          .map((dia) => DropdownMenuItem(
                                value: dia,
                                child: Text(dia.padLeft(2, '0')),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Mes'),
                      value: _mesSeleccionado,
                      onChanged: (String? nuevoMes) {
                        setState(() {
                          _mesSeleccionado = nuevoMes;
                        });
                      },
                      items: List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'))
                          .map((mes) => DropdownMenuItem(
                                value: mes,
                                child: Text(mes),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Año'),
                      value: _anioSeleccionado,
                      onChanged: (String? nuevoAnio) {
                        setState(() {
                          _anioSeleccionado = nuevoAnio;
                        });
                      },
                      items: _aniosDisponibles
                          .map((anio) => DropdownMenuItem(
                                value: anio,
                                child: Text(anio),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Hora'),
                      value: _horaSeleccionada,
                      onChanged: (String? nuevaHora) {
                        setState(() {
                          _horaSeleccionada = nuevaHora;
                        });
                      },
                      items: _horasDisponibles
                          .map((hora) => DropdownMenuItem(
                                value: hora,
                                child: Text(hora),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Minutos'),
                      value: _minutoSeleccionado,
                      onChanged: (String? nuevoMinuto) {
                        setState(() {
                          _minutoSeleccionado = nuevoMinuto;
                        });
                      },
                      items: _minutosDisponibles
                          .map((minuto) => DropdownMenuItem(
                                value: minuto,
                                child: Text(minuto),
                              ))
                          .toList(),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('AM/PM'),
                      value: _amPmSeleccionado,
                      onChanged: (String? nuevoAmPm) {
                        setState(() {
                          _amPmSeleccionado = nuevoAmPm;
                        });
                      },
                      items: ['AM', 'PM']
                          .map((amPm) => DropdownMenuItem(
                                value: amPm,
                                child: Text(amPm),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
              DropdownButton<String>(
                hint: Text('Selecciona la categoría'),
                value: _categoriaSeleccionada,
                onChanged: (String? nuevaCategoria) {
                  setState(() {
                    _categoriaSeleccionada = nuevaCategoria;
                  });
                },
                items: ['cultural', 'academica', 'deportiva']
                    .map((categoria) => DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria.capitalize()),
                        ))
                    .toList(),
              ),
              TextField(
                controller: _valorController,
                decoration: InputDecoration(labelText: 'Valor (en horas)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                hint: Text('Selecciona el estado'),
                value: _estadoSeleccionado,
                onChanged: (String? nuevoEstado) {
                  setState(() {
                    _estadoSeleccionado = nuevoEstado;
                  });
                },
                items: ['activo', 'cerrado']
                    .map((estado) => DropdownMenuItem(
                          value: estado,
                          child: Text(estado.capitalize()),
                        ))
                    .toList(),
              ),
              TextField(
                controller: _lugarController,
                decoration: InputDecoration(labelText: 'Lugar'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _crearActividad,
                child: Text('Crear Actividad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
