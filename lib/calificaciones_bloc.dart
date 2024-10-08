import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

class CalificacionesBloc
    extends Bloc<EventoCalificacion, EstadoCalificaciones> {
  final List<String> _alumnos = [
    'Juan',
    'Frnacisco',
    'Paco',
    'Pancho',
    'Curro',
    'Cisco',
    'Kiko'
  ];

  final List<String> _aprobados = [];
  List<String> get aprobados => UnmodifiableListView(_aprobados);
  final List<String> _reprobados = [];
  List<String> get reprobados => UnmodifiableListView(_reprobados);

  List<String> get alumnos => UnmodifiableListView(_alumnos);
  int _indice = 0;
  int get indice => _indice;

  CalificacionesBloc() : super(EstadoInicial()) {
    on<CambioTab>((event, emit) {
      _indice = event.indice;
      emit(NuevoTab(indice: _indice));
    });
    on<Revision>((event, emit) {
      _alumnos.add(event.nombre);
      _aprobados.removeWhere((element) => element == event.nombre);
      _reprobados.removeWhere(
        (element) => element == event.nombre,
      );
      emit(CambioAlumno(nombre: event.nombre));
    });
    on<Aprobado>((event, emit) {
      _aprobados.add(event.nombre);
      _alumnos.removeWhere((element) => element == event.nombre);
      _reprobados.removeWhere(
        (element) => element == event.nombre,
      );
      emit(CambioAlumno(nombre: event.nombre));
    });
    on<Reprobado>((event, emit) {
      _reprobados.add(event.nombre);
      _alumnos.removeWhere((element) => element == event.nombre);
      _aprobados.removeWhere(
        (element) => element == event.nombre,
      );
      emit(CambioAlumno(nombre: event.nombre));
    });
  }
}

sealed class EventoCalificacion {}

class CambioTab extends EventoCalificacion {
  final int indice;

  CambioTab({required this.indice});
}

sealed class EstadoCalificaciones {}

class NuevoTab extends EstadoCalificaciones {
  final int indice;

  NuevoTab({required this.indice});
}

class CambioAlumno extends EstadoCalificaciones {
  final String nombre;

  CambioAlumno({required this.nombre});
}

abstract class EventoAlumno extends EventoCalificacion {
  final String nombre;

  EventoAlumno({required this.nombre});
}

class Aprobado extends EventoAlumno {
  Aprobado({required super.nombre});
}

class Reprobado extends EventoAlumno {
  Reprobado({required super.nombre});
}

class Revision extends EventoAlumno {
  Revision({required super.nombre});
}

class EstadoInicial extends EstadoCalificaciones {}
