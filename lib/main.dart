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
                  2 => ListaReprobado(alumnos: estado.reprobados),
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

class ListaReprobado extends StatelessWidget {
  final List<String> alumnos;

  const ListaReprobado({super.key, required this.alumnos});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => Elemento(
          alumno: alumnos[index],
          funcionLista: funcionalidadReprobados,
          opciones: const {"Revision", "Aprobados"}),
    );
  }

  void funcionalidadReprobados(
      BuildContext context, DismissDirection direction, String alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(Revision(nombre: alumno));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(Aprobado(nombre: alumno));
    }
  }
}

class ListaPorCalificar extends StatelessWidget {
  final List<String> alumnos;
  const ListaPorCalificar({super.key, required this.alumnos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => Elemento(
        alumno: alumnos[index],
        funcionLista: funcionalidadRevision,
        opciones: const {"Aprobados", "Reprobados"},
      ),
    );
  }

  void funcionalidadRevision(
      BuildContext context, DismissDirection direction, String alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(Aprobado(nombre: alumno));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(Reprobado(nombre: alumno));
    }
  }
}

class ListaAprobados extends StatelessWidget {
  final List<String> alumnos;
  const ListaAprobados({super.key, required this.alumnos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => Elemento(
        alumno: alumnos[index],
        funcionLista: funcionalidadAprobados,
        opciones: const {"Revision", "Reprobar"},
      ),
    );
  }

  void funcionalidadAprobados(
      BuildContext context, DismissDirection direction, String alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(Revision(nombre: alumno));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(Reprobado(nombre: alumno));
    }
  }
}

class Elemento extends StatelessWidget {
  final String alumno;
  final Function funcionLista;
  final Set<String> opciones;
  const Elemento(
      {super.key,
      required this.alumno,
      required this.funcionLista,
      required this.opciones});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.horizontal,
      background: ColoredBox(
        color: Colors.green,
        child: Text(opciones.elementAt(0)),
      ),
      secondaryBackground: ColoredBox(
        color: Colors.yellow,
        child: Text(opciones.elementAt(1)),
      ),
      onDismissed: (direction) {
        funcionLista(context, direction, alumno);
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
