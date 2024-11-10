import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModificarActividad extends StatefulWidget {
  final String actividadId;
  final Map<String, dynamic> actividadData;

  ModificarActividad({required this.actividadId, required this.actividadData});

  @override
  _ModificarActividadPageState createState() => _ModificarActividadPageState();
}

class _ModificarActividadPageState extends State<ModificarActividad> {
  late TextEditingController _nombreController;
  late TextEditingController _valorController;
  late TextEditingController _lugarController;

  String? _diaSeleccionado;
  String? _mesSeleccionado;
  String? _anioSeleccionado;
  String? _horaSeleccionada;
  String? _minutoSeleccionado;
  String? _amPmSeleccionado;
  String? _categoriaSeleccionada;
  String? _estadoSeleccionado;

  List<String> _diasDisponibles = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _aniosDisponibles = List.generate(11, (index) => (2020 + index).toString());
  List<String> _horasDisponibles = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
  List<String> _minutosDisponibles = List.generate(60, (index) => (index).toString().padLeft(2, '0'));

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.actividadData['nombre']);
    _valorController = TextEditingController(text: widget.actividadData['valor'].toString());
    _lugarController = TextEditingController(text: widget.actividadData['lugar']);

    // Obtener la fecha y hora actuales de la actividad
    Timestamp? fechaHoraTimestamp = widget.actividadData['fechaHora'];
    if (fechaHoraTimestamp != null) {
      DateTime fechaHora = fechaHoraTimestamp.toDate();
      _diaSeleccionado = fechaHora.day.toString().padLeft(2, '0');
      _mesSeleccionado = fechaHora.month.toString().padLeft(2, '0');
      _anioSeleccionado = fechaHora.year.toString();
      _horaSeleccionada = (fechaHora.hour % 12 == 0 ? 12 : fechaHora.hour % 12).toString().padLeft(2, '0');
      _minutoSeleccionado = fechaHora.minute.toString().padLeft(2, '0');
      _amPmSeleccionado = fechaHora.hour >= 12 ? 'PM' : 'AM';
    }

    _categoriaSeleccionada = widget.actividadData['categoria'];
    _estadoSeleccionado = widget.actividadData['estado'];

    _actualizarDiasDisponibles(_mesSeleccionado!, _anioSeleccionado!);
  }

  // Función para verificar si un año es bisiesto
  bool _esBisiesto(int anio) {
    return (anio % 4 == 0 && anio % 100 != 0) || (anio % 400 == 0);
  }

  // Función para ajustar la lista de días según el mes seleccionado y el año
  void _actualizarDiasDisponibles(String mes, String anio) {
    setState(() {
      int? anioInt = int.tryParse(anio);
      bool esBisiesto = anioInt != null && _esBisiesto(anioInt);

      if (mes == '04' || mes == '06' || mes == '09' || mes == '11') {
        _diasDisponibles = List.generate(30, (index) => (index + 1).toString().padLeft(2, '0'));
      } else if (mes == '02') {
        _diasDisponibles = esBisiesto ? List.generate(29, (index) => (index + 1).toString().padLeft(2, '0')) : List.generate(28, (index) => (index + 1).toString().padLeft(2, '0'));
      } else {
        _diasDisponibles = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));
      }

      // Si el día seleccionado no está en la nueva lista, se restablece
      if (!_diasDisponibles.contains(_diaSeleccionado)) {
        _diaSeleccionado = null;
      }
    });
  }

  // Función para crear un timestamp a partir de la fecha y hora seleccionadas
  Timestamp _crearTimestamp() {
    int dia = int.parse(_diaSeleccionado!);
    int mes = int.parse(_mesSeleccionado!);
    int anio = int.parse(_anioSeleccionado!);
    int hora = int.parse(_horaSeleccionada!);
    int minuto = int.parse(_minutoSeleccionado!);

    // Ajuste para AM/PM
    if (_amPmSeleccionado == 'PM' && hora != 12) {
      hora += 12;
    } else if (_amPmSeleccionado == 'AM' && hora == 12) {
      hora = 0;
    }

    return Timestamp.fromDate(DateTime(anio, mes, dia, hora, minuto));
  }

  Future<void> _modificarActividad() async {
    // Validar que el valor en horas sea numérico
    int? valorEnHoras = int.tryParse(_valorController.text);
    if (valorEnHoras == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El valor en horas debe ser un número')),
      );
      return;
    }

    // Crear el timestamp para la fecha y la hora
    Timestamp fechaHoraTimestamp = _crearTimestamp();

    try {
      await FirebaseFirestore.instance
          .collection('activities')
          .doc(widget.actividadId)
          .update({
        'nombre': _nombreController.text,
        'fechaHora': fechaHoraTimestamp, // Guardar como timestamp
        'categoria': _categoriaSeleccionada,
        'valor': valorEnHoras,
        'estado': _estadoSeleccionado,
        'lugar': _lugarController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Actividad modificada exitosamente')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al modificar la actividad: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Actividad'),
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
                                child: Text(dia),
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
                          if (_anioSeleccionado != null) {
                            _actualizarDiasDisponibles(nuevoMes!, _anioSeleccionado!);
                          }
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
                          if (_mesSeleccionado != null) {
                            _actualizarDiasDisponibles(_mesSeleccionado!, nuevoAnio!);
                          }
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
                onPressed: _modificarActividad,
                child: Text('Guardar Cambios'),
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
