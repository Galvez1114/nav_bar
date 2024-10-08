import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_bar/calificaciones_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => CalificacionesBloc(),
        child: BlocBuilder<CalificacionesBloc, EstadoCalificaciones>(
          builder: (context, state) {
            var estado = context.watch<CalificacionesBloc>();
            return Scaffold(
              bottomNavigationBar: BarraNavegacion(indice: estado.indice),
              body: Center(
                child: switch (estado.indice) {
                  0 => ListaPorCalificar(alumnos: estado.alumnos),
                  1 => ListaAprobados(alumnos: estado.aprobados),
                  2 => ListaReprobados(alumnos: estado.reprobados),
                  _ => const Advertencia(),
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class Advertencia extends StatelessWidget {
  const Advertencia({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('No debes estar aqui');
  }
}

class ListaPorCalificar extends StatelessWidget {
  final List<String> alumnos;
  const ListaPorCalificar({super.key, required this.alumnos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => Elemento(alumno: alumnos[index]),
    );
  }
}

class ListaAprobados extends StatelessWidget {
  final List<String> alumnos;
  const ListaAprobados({super.key, required this.alumnos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => ElementoRevisado(alumno: alumnos[index]),
    );
  }
}

class ListaReprobados extends StatelessWidget {
  final List<String> alumnos;
  const ListaReprobados({super.key, required this.alumnos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => ElementoRevisado(alumno: alumnos[index]),
    );
  }
}

class Elemento extends StatelessWidget {
  final String alumno;
  const Elemento({super.key, required this.alumno});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      background: const ColoredBox(
        color: Colors.green,
        child: Text('Aprobarlo'),
      ),
      secondaryBackground: const ColoredBox(
        color: Colors.yellow,
        child: Text(
          'Reprobarlo',
          textAlign: TextAlign.right,
        ),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          context.read<CalificacionesBloc>().add(Aprobado(nombre: alumno));
        }
        if (direction == DismissDirection.endToStart) {
          context.read<CalificacionesBloc>().add(Reprobado(nombre: alumno));
        }
      },
      key: UniqueKey(),
      child: ListTile(
        title: Text(alumno),
        style: ListTileStyle.list,
      ),
    );
  }
}

class ElementoRevisado extends StatelessWidget {
  final String alumno;
  const ElementoRevisado({super.key, required this.alumno});

  @override
  Widget build(BuildContext context) {
    var estado = context.watch<CalificacionesBloc>();
    return Dismissible(
      direction: DismissDirection.horizontal,
      background: const ColoredBox(
        color: Colors.blue,
        child: Text('Mandarlo a revisión'),
      ),
      secondaryBackground: switch (estado.indice) {
        1 => const ColoredBox(
            color: Colors.yellow,
            child: Text('Reprobarlo', textAlign: TextAlign.right),
          ),
        2 => const ColoredBox(
            color: Colors.green,
            child: Text('Aprobarlo', textAlign: TextAlign.right),
          ),
        _ => const ColoredBox(
            color: Colors.red,
            child: Text('Est no deberia salir', textAlign: TextAlign.right),
          )
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          context.read<CalificacionesBloc>().add(Revision(nombre: alumno));
        }
        if (estado.indice == 1 && direction == DismissDirection.endToStart) {
          context.read<CalificacionesBloc>().add(Reprobado(nombre: alumno));
        }
        if (estado.indice == 2 && direction == DismissDirection.endToStart) {
          context.read<CalificacionesBloc>().add(Aprobado(nombre: alumno));
        }
      },
      key: UniqueKey(),
      child: ListTile(
        title: Text(alumno),
        style: ListTileStyle.list,
      ),
    );
  }
}

class BarraNavegacion extends StatelessWidget {
  final int indice;
  const BarraNavegacion({super.key, required this.indice});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
        indicatorColor: Colors.purple,
        selectedIndex: indice,
        onDestinationSelected: (value) {
          context.read<CalificacionesBloc>().add(CambioTab(indice: value));
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.alarm), label: 'Por revisar'),
          NavigationDestination(icon: Icon(Icons.home), label: 'Aprobados'),
          NavigationDestination(icon: Icon(Icons.error), label: 'Reprobados')
        ]);
  }
}
