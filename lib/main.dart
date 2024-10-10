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
            var bloc = context.watch<CalificacionesBloc>();
            return Scaffold(
              bottomNavigationBar: BarraNavegacion(indice: bloc.indice),
              body: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: switch (bloc.indice) {
                        0 => ListaPorCalificar(
                            alumnos: bloc.ordenado
                                ? bloc.alumnoOrdenado
                                : bloc.revision),
                        1 => ListaAprobados(
                            alumnos: bloc.ordenado
                                ? bloc.alumnoOrdenado
                                : bloc.aprobados),
                        2 => ListaReprobado(
                            alumnos: bloc.ordenado
                                ? bloc.alumnoOrdenado
                                : bloc.reprobados),
                        _ => const Advertencia(),
                      },
                    ),
                  ),
                  ButtonListAction(bloc: bloc)
                ],
              ),
              floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showAlertDialog(context, bloc);
                  }),
            );
          },
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context, CalificacionesBloc bloc) {
    TextEditingController alumnoController = TextEditingController();
    // set up the button
    Widget AgregarButton = TextButton(
      child: const Text("Agregar"),
      onPressed: () {
        context
            .read<CalificacionesBloc>()
            .add(AgregarAlumno(bloc.indice, nombre: alumnoController.text));
        Navigator.of(context).pop();
      },
    );

    Widget CancelarButton = TextButton(
      child: const Text("Cancelar"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget nombreAlumno = TextField(
      controller: alumnoController,
      decoration: const InputDecoration(label: Text("Ingresar nombre alumno")),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Agregar alumno"),
      content: nombreAlumno,
      actions: [CancelarButton, AgregarButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class ButtonListAction extends StatelessWidget {
  const ButtonListAction({
    super.key,
    required this.bloc,
  });

  final CalificacionesBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      children: [
        BotonOrdenamiento(bloc: bloc),
      ],
    ));
  }
}

class BotonOrdenamiento extends StatelessWidget {
  const BotonOrdenamiento({
    super.key,
    required this.bloc,
  });

  final CalificacionesBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () {
            context
                .read<CalificacionesBloc>()
                .add(OrdenarAlfabetico(bloc.ordenado));
          },
          child: Text(bloc.ordenado
              ? "No ordenar alfabéticamente"
              : "Ordenar alfabéticamente")),
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
          opciones: const {"Revision": Colors.blue, "Aprobados": Colors.green}),
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
        opciones: const {
          "Aprobados": Colors.green,
          "Reprobados": Colors.yellow
        },
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
        opciones: const {"Revision": Colors.blue, "Reprobados": Colors.yellow},
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

class ListaReprobados extends StatelessWidget {
  final List<String> alumnos;
  const ListaReprobados({super.key, required this.alumnos});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: alumnos.length,
      itemBuilder: (context, index) => Elemento(
        alumno: alumnos[index],
        funcionLista: funcionalidadAprobados,
        opciones: const {"Revision": Colors.blue, "Aprobados": Colors.green},
      ),
    );
  }

  void funcionalidadAprobados(
      BuildContext context, DismissDirection direction, String alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(Revision(nombre: alumno));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(Aprobado(nombre: alumno));
    }
  }
}

class Elemento extends StatelessWidget {
  final String alumno;
  final Function funcionLista;
  final Map<String, Color> opciones;
  const Elemento(
      {super.key,
      required this.alumno,
      required this.funcionLista,
      required this.opciones});

  @override
  Widget build(BuildContext context) {
    String opcion1 = opciones.keys.elementAt(0);
    String opcion2 = opciones.keys.elementAt(1);
    return Dismissible(
      direction: DismissDirection.horizontal,
      background: ColoredBox(
        color: opciones[opcion1]!,
        child: Text(opcion1),
      ),
      secondaryBackground: ColoredBox(
        color: opciones[opcion2]!,
        child: Container(alignment: Alignment.topRight, child: Text(opcion2)),
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
