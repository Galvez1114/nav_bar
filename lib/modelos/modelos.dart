import 'dart:collection';

import 'package:nav_bar/db/db_constantes.dart';

class AlumnosHandler {
  List<Alumno> _revision = [];
  List<Alumno> _aprobados = [];
  List<Alumno> _reprobados = [];
  late List<Alumno> alumnoOrdenado;

  List<Alumno> get aprobados => UnmodifiableListView(_aprobados);
  List<Alumno> get reprobados => UnmodifiableListView(_reprobados);
  List<Alumno> get revision => UnmodifiableListView(_revision);

  void ordenar(indice) {
    alumnoOrdenado = switch (indice) {
      0 => List<Alumno>.from(revision),
      1 => List<Alumno>.from(aprobados),
      2 => List<Alumno>.from(reprobados),
      _ => []
    };
    alumnoOrdenado.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  bool addAlumno(Alumno alumno) {
    if (!alumnoExists(alumno)) {
      _revision.add(Alumno(
          name: alumno.name,
          estadoCalificacion: alumno.estadoCalificacion,
          calificacion: alumno.calificacion));
      return true;
    }
    return false;
  }

  bool alumnoExists(Alumno alumno) {
    return _revision.contains(alumno) ||
        _aprobados.contains(alumno) ||
        _reprobados.contains(alumno);
  }

  void inicLists(List<Alumno> alumnos, TiposListas lista) {
    switch (lista) {
      case TiposListas.revision:
        _revision = alumnos;
        return;
      case TiposListas.aprobados:
        _aprobados = alumnos;
        return;
      case TiposListas.reprobados:
        _reprobados = alumnos;
        return;
    }
  }

  void cambiarCalificacion(Alumno alumno, int nuevaCalificacion) {
    int index = _revision.indexOf(alumno);
    _revision[index] = Alumno(
        name: alumno.name,
        estadoCalificacion: alumno.estadoCalificacion,
        calificacion: nuevaCalificacion);
  }

  void cambioEstado(Alumno alumno, TiposListas fromList, TiposListas toList) {
    removerDeLista(fromList, alumno);
    switch (toList) {
      case TiposListas.revision:
        alumno.estadoCalificacion = estadoRevision;
        _revision.add(alumno);
        return;
      case TiposListas.aprobados:
        alumno.estadoCalificacion = estadoAprobado;
        _aprobados.add(alumno);
        return;
      case TiposListas.reprobados:
        alumno.estadoCalificacion = estadoReprobado;
        _reprobados.add(alumno);
        return;
    }
  }

  void removerDeLista(TiposListas lista, Alumno alumno) {
    switch (lista) {
      case TiposListas.revision:
        _revision.removeWhere((element) => element == alumno);
        return;
      case TiposListas.aprobados:
        _aprobados.removeWhere((element) => element == alumno);
        return;
      case TiposListas.reprobados:
        _reprobados.removeWhere((element) => element == alumno);
        return;
    }
  }
}

class Alumno {
  final String name;
  String estadoCalificacion;
  final int calificacion;

  Alumno(
      {required this.name,
      required this.estadoCalificacion,
      required this.calificacion});
}

enum TiposListas { revision, aprobados, reprobados }
