import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_bar/db/db.dart';
import 'package:nav_bar/db/db_constantes.dart';
import 'package:nav_bar/modelos/modelos_db.dart';

class CalificacionesBloc
    extends Bloc<EventoCalificacion, EstadoCalificaciones> {
  final List<String> _aprobados = [];
  final List<String> _reprobados = [];
  final List<String> _revision = [];
  final Map<String, int> _calificaciones = {};
  late List<String> alumnoOrdenado;

  List<String> get aprobados => UnmodifiableListView(_aprobados);
  List<String> get reprobados => UnmodifiableListView(_reprobados);
  List<String> get revision => UnmodifiableListView(_revision);
  Map<String, int> get calificaciones => _calificaciones;

  bool ordenado = false;
  int _indice = 0;
  int get indice => _indice;

  SQLDatabase db = SQLDatabase();

  CalificacionesBloc() : super(EstadoInicial()) {
    on<ExtractDBData>((event, emit) async {
      await db.connectionDatabase();
      List<Alumno> listaAlumnos = await db.getAlumnosAsList();
      for (var alumno in listaAlumnos) {
        _calificaciones[alumno.name] = alumno.calificacion;
        switch (alumno.estadoCalificacion) {
          case estadoRevision:
            _revision.add(alumno.name);
            break;
          case estadoAprobado:
            _aprobados.add(alumno.name);
            break;
          case estadoReprobado:
            _reprobados.add(alumno.name);
            break;
          default:
            print("Este valor no está implementado");
            break;
        }
      }
      emit(NuevoTab(indice: _indice));
    });
    on<CambioTab>((event, emit) async {
      await db.getAlumnosAsList();
      _indice = event.indice;
      ordenado = false;
      emit(NuevoTab(indice: _indice));
    });
    on<Revision>((event, emit) async {
      _revision.add(event.nombre);
      _aprobados.removeWhere((element) => element == event.nombre);
      _reprobados.removeWhere(
        (element) => element == event.nombre,
      );
      await db.updateEstadoAlumno(estadoRevision, event.nombre);
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.nombre,
        );
      }
      emit(CambioAlumno(nombre: event.nombre));
    });
    on<Aprobado>((event, emit) async {
      _aprobados.add(event.nombre);
      _revision.removeWhere((element) => element == event.nombre);
      _reprobados.removeWhere(
        (element) => element == event.nombre,
      );
      await db.updateEstadoAlumno(estadoAprobado, event.nombre);
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.nombre,
        );
      }
      emit(CambioAlumno(nombre: event.nombre));
    });
    on<Reprobado>((event, emit) async {
      _reprobados.add(event.nombre);
      _revision.removeWhere((element) => element == event.nombre);
      _aprobados.removeWhere(
        (element) => element == event.nombre,
      );
      await db.updateEstadoAlumno(estadoReprobado, event.nombre);
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.nombre,
        );
      }
      emit(CambioAlumno(nombre: event.nombre));
    });

    on<OrdenarAlfabetico>((event, emit) {
      ordenar();
      ordenado = !ordenado;
      emit(NuevoTab(indice: indice));
    });
    on<AgregarAlumno>((event, emit) async {
      if (!(_revision.contains(event.nombre) ||
          _aprobados.contains(event.nombre) ||
          _reprobados.contains(event.nombre))) {
        _revision.add(event.nombre);
        await db.insertAlumno(event.nombre, estadoRevision, 0);
        if (ordenado && event.indice == 0) {
          alumnoOrdenado.add(event.nombre);
          ordenar();
        }
      }
      emit(NuevoTab(indice: indice));
    });
    on<EliminarAlumno>((event, emit) async {
      _revision.removeWhere(
        (element) => element == event.nombre,
      );
      await db.deleteAlumno(event.nombre);
      if (ordenado && indice == 0) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.nombre,
        );
      }
      emit(NuevoTab(indice: indice));
    });

    on<Calificar>((event, emit) async {
      _calificaciones[event.alumno] = event.calificacion;
      await db.updateCalificacion(event.calificacion.toString(), event.alumno);
      emit(NuevoTab(indice: indice));
    });
  }

  void ordenar() {
    alumnoOrdenado = switch (indice) {
      0 => List<String>.from(revision),
      1 => List<String>.from(aprobados),
      2 => List<String>.from(reprobados),
      _ => ["No se encontró la lista"]
    };
    alumnoOrdenado.sort((a, b) {
      return a.toLowerCase().compareTo(b.toLowerCase());
    });
  }
}

sealed class EventoCalificacion {}

class CambioTab extends EventoCalificacion {
  final int indice;

  CambioTab({required this.indice});
}

class Calificar extends EventoCalificacion {
  final int calificacion;
  final String alumno;
  Calificar({required this.alumno, required this.calificacion});
}

class ExtractDBData extends EventoCalificacion {}

sealed class EstadoCalificaciones {} //********************************************************** */

class AgregandoAlumnoEstado extends EstadoCalificaciones {}

class NuevoTab extends EstadoCalificaciones {
  final int indice;
  NuevoTab({required this.indice});
}

class CambioAlumno extends EstadoCalificaciones {
  final String nombre;

  CambioAlumno({required this.nombre});
}

abstract class EventoAlumno extends EventoCalificacion {
  // ****************************************
  final String nombre;

  EventoAlumno({required this.nombre});
}

class EliminarAlumno extends EventoAlumno {
  EliminarAlumno({required super.nombre});
}

class AgregarAlumno extends EventoAlumno {
  final int indice;

  AgregarAlumno(this.indice, {required super.nombre});
}

class OrdenarAlfabetico extends EventoAlumno {
  final bool ordenar;
  OrdenarAlfabetico(this.ordenar) : super(nombre: '');
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
