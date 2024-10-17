import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_bar/db/db.dart';
import 'package:nav_bar/db/db_constantes.dart';
import 'package:nav_bar/modelos/modelos.dart';

class CalificacionesBloc
    extends Bloc<EventoCalificacion, EstadoCalificaciones> {
  AlumnosHandler alumnos = AlumnosHandler();
  late List<Alumno> alumnoOrdenado;

  bool ordenado = false;
  int _indice = 0;
  int get indice => _indice;

  SQLDatabase db = SQLDatabase();

  CalificacionesBloc() : super(EstadoInicial()) {
    on<ExtractDBData>((event, emit) async {
      await db.connectionDatabase();
      List<Alumno> listaAlumnos = await db.getAlumnosAsList();
      for (var alumno in listaAlumnos) {
        switch (alumno.estadoCalificacion) {
          case estadoRevision:
            alumnos.inicLists(listaAlumnos, TiposListas.revision);
            break;
          case estadoAprobado:
            alumnos.inicLists(listaAlumnos, TiposListas.aprobados);
            break;
          case estadoReprobado:
            alumnos.inicLists(listaAlumnos, TiposListas.reprobados);
            break;
          default:
            //VALOR NO IMPLEMENTADO.
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
    on<MandarARevision>((event, emit) async {
      alumnos.cambioEstado(event.alumno, event.fromList, TiposListas.revision);
      await db.updateEstadoAlumno(estadoRevision, event.alumno.name);
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.alumno,
        );
      }
      emit(CambioAlumno(nombre: event.alumno));
    });
    on<MandarAAprobados>((event, emit) async {
      alumnos.cambioEstado(event.alumno, event.fromList, TiposListas.aprobados);
      await db.updateEstadoAlumno(estadoAprobado, event.alumno.name);
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.alumno,
        );
      }
      emit(CambioAlumno(nombre: event.alumno));
    });
    on<MandarAReprobados>((event, emit) async {
      alumnos.cambioEstado(
          event.alumno, event.fromList, TiposListas.reprobados);
      await db.updateEstadoAlumno(estadoReprobado, event.alumno.name);
      if (ordenado) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.alumno,
        );
      }
      emit(CambioAlumno(nombre: event.alumno));
    });

    on<OrdenarAlfabetico>((event, emit) {
      ordenar(indice);
      ordenado = !ordenado;
      emit(NuevoTab(indice: indice));
    });
    on<AgregarAlumno>((event, emit) async {
      alumnos.addAlumno(event.alumno);
      await db.insertAlumno(event.alumno.name, estadoRevision, 0);
      if (ordenado && event.indice == 0) {
        alumnoOrdenado.add(event.alumno);
        ordenar(indice);
      }
      emit(NuevoTab(indice: indice));
    });
    on<EliminarAlumno>((event, emit) async {
      alumnos.removerDeLista(TiposListas.revision, event.alumno);
      await db.deleteAlumno(event.alumno.name);
      if (ordenado && indice == 0) {
        alumnoOrdenado.removeWhere(
          (element) => element == event.alumno,
        );
      }
      emit(NuevoTab(indice: indice));
    });

    on<Calificar>((event, emit) async {
      alumnos.cambiarCalificacion(event.alumno, event.calificacion);
      await db.updateCalificacion(
          event.calificacion.toString(), event.alumno.name);
      emit(NuevoTab(indice: indice));
    });
  }

  void ordenar(indice) {
    alumnoOrdenado = switch (indice) {
      0 => List<Alumno>.from(alumnos.revision),
      1 => List<Alumno>.from(alumnos.aprobados),
      2 => List<Alumno>.from(alumnos.reprobados),
      _ => []
    };
    alumnoOrdenado.sort((a, b) {
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
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
  final Alumno alumno;
  Calificar({required this.alumno, required this.calificacion});
}

class ExtractDBData extends EventoCalificacion {}

sealed class EstadoCalificaciones {} //********************************************************** */

class AgregandoAlumnoEstado extends EstadoCalificaciones {}

class DBCargada extends EstadoCalificaciones {}

class NuevoTab extends EstadoCalificaciones {
  final int indice;
  NuevoTab({required this.indice});
}

class CambioAlumno extends EstadoCalificaciones {
  final Alumno nombre;

  CambioAlumno({required this.nombre});
}

abstract class EventoAlumno extends EventoCalificacion {
  // ****************************************
  final Alumno alumno;

  EventoAlumno({required this.alumno});
}

class EliminarAlumno extends EventoAlumno {
  EliminarAlumno({required super.alumno});
}

class AgregarAlumno extends EventoAlumno {
  final int indice;

  AgregarAlumno(this.indice, {required super.alumno});
}

class OrdenarAlfabetico extends EventoAlumno {
  final bool ordenar;
  OrdenarAlfabetico(this.ordenar)
      : super(
            alumno: Alumno(
                name: "", estadoCalificacion: estadoRevision, calificacion: 0));
}

class MandarAAprobados extends EventoAlumno {
  final TiposListas fromList;
  MandarAAprobados({required this.fromList, required super.alumno});
}

class MandarAReprobados extends EventoAlumno {
  final TiposListas fromList;
  MandarAReprobados({required this.fromList, required super.alumno});
}

class MandarARevision extends EventoAlumno {
  final TiposListas fromList;
  MandarARevision({required this.fromList, required super.alumno});
}

class EstadoInicial extends EstadoCalificaciones {}
