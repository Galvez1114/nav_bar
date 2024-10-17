import 'dart:collection';

import 'package:nav_bar/db/db_constantes.dart';

class AlumnosHandler {
  List<Alumno> _revision = [];
  List<Alumno> _aprobados = [];
  List<Alumno> _reprobados = [];

  List<Alumno> get aprobados => UnmodifiableListView(_aprobados);
  List<Alumno> get reprobados => UnmodifiableListView(_reprobados);
  List<Alumno> get revision => UnmodifiableListView(_revision);

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

class OrdenadosAlumnos {
  List<Alumno> alumnosOrdenado = [];
  final String alfabetico = "Alfabetico";
  final String descendente = "Descendente";
  late final Map<String, bool> _ordenado = {
    alfabetico: false,
    descendente: false,
  };

  bool get ordenadoAlfabetico => _ordenado[alfabetico]!;
  bool get ordenadoDescendente => _ordenado[descendente]!;

  void cambiarOrdenado(String ordenamiento, bool valorOrdenamiento) {
    _ordenado.updateAll((key, value) {
      return key != ordenamiento ? false : valorOrdenamiento;
    });
  }

  bool estaOrdenada() {
    return _ordenado.values.any(
      (element) => element == true,
    );
  }

  void ordenar(AlumnosHandler alumnos, indice) {
    if (_ordenado[alfabetico]!) {
      _ordenarAlfabetico(alumnos, indice);
      return;
    }
    if (_ordenado[descendente]!) {
      _ordenarDescendente(alumnos, indice);
      return;
    }
  }

  void _ordenarAlfabetico(AlumnosHandler alumnos, indice) {
    alumnosOrdenado = switch (indice) {
      0 => List<Alumno>.from(alumnos.revision),
      1 => List<Alumno>.from(alumnos.aprobados),
      2 => List<Alumno>.from(alumnos.reprobados),
      _ => []
    };
    alumnosOrdenado.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  void _ordenarDescendente(AlumnosHandler alumnos, indice) {
    alumnosOrdenado = switch (indice) {
      0 => List<Alumno>.from(alumnos.revision),
      1 => List<Alumno>.from(alumnos.aprobados),
      2 => List<Alumno>.from(alumnos.reprobados),
      _ => []
    };
    alumnosOrdenado.sort((a, b) {
      return a.calificacion.compareTo(b.calificacion);
    });
  }
}

enum TiposListas { revision, aprobados, reprobados }
