import 'package:flutter/material.dart';

class PantallaDetallesAlumno extends StatelessWidget {
  final String nombre;
  final int calificacion;
  final String estado;

  const PantallaDetallesAlumno(
      {super.key,
      required this.nombre,
      required this.calificacion,
      required this.estado});

  @override
  Widget build(BuildContext context) {
    double principal = 20;
    double pantallaWidth = MediaQuery.of(context).size.width;
    double pantallaHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de alumno'),
        backgroundColor: const Color.fromARGB(255, 7, 135, 255),
      ),
      body: Column(
        children: [
          Icon(
            Icons.person,
            size: pantallaHeight * 0.2,
            color: Colors.deepPurple,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              margin: EdgeInsets.symmetric(
                  horizontal: pantallaWidth * .3,
                  vertical: pantallaHeight * 0.03),
              elevation: 8, // Sombra de la tarjeta
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15), // Bordes redondeados
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextoNombreAlumno(nombre: nombre, principal: principal),
                    TextoCalificacion(
                        calificacion: calificacion, principal: principal),
                    TextoEstadoAlumno(estado: estado, principal: principal),
                  ],
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.red)),
            child: const Text(
              'Regresar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class TextoNombreAlumno extends StatelessWidget {
  const TextoNombreAlumno({
    super.key,
    required this.nombre,
    required this.principal,
  });

  final String nombre;
  final double principal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Nombre: $nombre',
        style: TextStyle(fontSize: principal),
      ),
    );
  }
}

class TextoEstadoAlumno extends StatelessWidget {
  const TextoEstadoAlumno({
    super.key,
    required this.estado,
    required this.principal,
  });

  final String estado;
  final double principal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Estado: $estado',
        style: TextStyle(
            fontSize: principal,
            color: switch (estado) {
              'aprobado' => Colors.blue,
              'reprobado' => Colors.red,
              _ => Colors.black
            }),
      ),
    );
  }
}

class TextoCalificacion extends StatelessWidget {
  const TextoCalificacion({
    super.key,
    required this.calificacion,
    required this.principal,
  });

  final int calificacion;
  final double principal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        'Calificación: $calificacion',
        style: TextStyle(
            fontSize: principal,
            color: switch (calificacion) {
              >= 70 => Colors.green,
              < 70 => Colors.red,
              _ => Colors.black
            }),
      ),
    );
  }
}
