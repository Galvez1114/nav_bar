import 'package:nav_bar/db/db_constantes.dart';
import 'package:nav_bar/modelos/modelos_db.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

class SQLDatabase {
  late Database _connection;

  Future<void> connectionDatabase() async {
    _connection = await openDatabase(NAME_DB);
    _createTable();
  }

  Future<void> _createTable() async {
    await _connection.execute(
        "CREATE TABLE IF NOT EXISTS $tablaAlumno ($columnaNombreAlumno TEXT PRIMARY KEY, $columnaEstadoCalificacion TEXT CHECK($columnaEstadoCalificacion IN ('$estadoRevision', '$estadoAprobado', '$estadoReprobado')), $columnaCalificacion INTEGER)");
  }

  Future<void> insertAlumno(
      String nameAlumno, String estadoCalificacion, int calificacion) async {
    await _connection.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO $tablaAlumno ($columnaNombreAlumno, $columnaEstadoCalificacion, $columnaCalificacion) VALUES("$nameAlumno", "$estadoCalificacion", "$calificacion")');
    });
  }

  Future<void> deleteAlumno(String nameAlumno) async {
    await _connection.transaction((txn) async {
      int id1 = await txn.rawDelete(
          'DELETE FROM $tablaAlumno WHERE $columnaNombreAlumno = "$nameAlumno"');
    });
  }

  Future<void> updateEstadoAlumno(String estado, String alumno) async {
    await _connection.transaction((txn) async {
      int id1 = await txn.rawUpdate(
          'UPDATE $tablaAlumno SET $columnaEstadoCalificacion = "$estado" WHERE $columnaNombreAlumno = "$alumno";');
    });
  }

  Future<void> updateCalificacion(String calificacion, String alumno) async {
    await _connection.transaction((txn) async {
      int id1 = await txn.rawUpdate(
          'UPDATE $tablaAlumno SET $columnaCalificacion = "$calificacion" WHERE $columnaNombreAlumno = "$alumno";');
    });
  }

  Future<List<Alumno>> getAlumnosAsList() async {
    List<Map<String, Object?>> consulta =
        await _connection.rawQuery('SELECT * FROM $tablaAlumno');
    List<Alumno> listValues = [];
    for (var alumno in consulta) {
      listValues.add(Alumno(
        name: alumno[columnaNombreAlumno] as String,
        estadoCalificacion: alumno[columnaEstadoCalificacion] as String,
        calificacion: alumno[columnaCalificacion] as int,
      ));
    }
    return listValues;
  }

  Future<bool> notExsistsAlumno(String alumno) async {
    List<Map<String, Object?>> consulta = await _connection.rawQuery(
        'SELECT * FROM $tablaAlumno WHERE $columnaNombreAlumno = "$alumno"');
    return consulta.isNotEmpty;
  }
}

void main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
  SQLDatabase db = SQLDatabase();
  await db.connectionDatabase();
  //await db._connection.execute("DROP TABLE $tablaAlumno");
  //await db._createTable();
  await db.insertAlumno("juan1", estadoRevision, 100);
  await db.insertAlumno("juan2", estadoAprobado, 70);
  await db.insertAlumno("juan3", estadoReprobado, 50);
}
