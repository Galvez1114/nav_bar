import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

class CalificacionesBloc
    extends Bloc<EventoCalificacion, EstadoCalificaciones> {
  final List<String> _aprobados = [];
  final List<String> _reprobados = [];
  final List<String> _revision = [
    'Juan',
    'Frnacisco',
    'Paco',
    'Pancho',
    'Curro',
    'Cisco',
    'Kiko'
  ];
  late List<String> alumnoOrdenado;

  List<String> get aprobados => UnmodifiableListView(_aprobados);

  List<String> get reprobados => UnmodifiableListView(_reprobados);
  List<String> get revision => UnmodifiableListView(_revision);

  bool ordenado = false;
  int _indice = 0;
  int get indice => _indice;

  CalificacionesBloc() : super(EstadoInicial()) {
    on<CambioTab>((event, emit) {
      _indice = event.indice;
      ordenado = false;
      emit(NuevoTab(indice: _indice));
    });
    on<Revision>((event, emit) {
      _revision.add(event.nombre);
      _aprobados.removeWhere((element) => element == event.nombre);
      _reprobados.removeWhere(
        (element) => element == event.nombre,
      );
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.nombre,
        );
      }
      emit(CambioAlumno(nombre: event.nombre));
    });
    on<Aprobado>((event, emit) {
      _aprobados.add(event.nombre);
      _revision.removeWhere((element) => element == event.nombre);
      _reprobados.removeWhere(
        (element) => element == event.nombre,
      );
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.nombre,
        );
      }
      emit(CambioAlumno(nombre: event.nombre));
    });
    on<Reprobado>((event, emit) {
      _reprobados.add(event.nombre);
      _revision.removeWhere((element) => element == event.nombre);
      _aprobados.removeWhere(
        (element) => element == event.nombre,
      );
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
    on<AgregarAlumno>((event, emit) {
      _revision.add(event.nombre);
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
