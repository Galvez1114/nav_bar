import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_bar/calificaciones_bloc.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future main() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  databaseFactory = databaseFactoryFfi;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (context) =>
            CalificacionesBloc()..add(ExtractDBData()),
        child: BlocBuilder<CalificacionesBloc, EstadoCalificaciones>(
          builder: (context, state) {
            var bloc = context.watch<CalificacionesBloc>();
            return Scaffold(
              bottomNavigationBar: BarraNavegacion(indice: bloc.indice),
              body: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: switch (bloc.state) {
                        EstadoInicial() => CargandoDBWidget(),
                        _ => switch (bloc.indice) {
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
                          }
                      },
                    ),
                  ),
                  ButtonListAction(bloc: bloc)
                ],
              ),
              floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    showAddAlertDialog(context, bloc);
                  }),
            );
          },
        ),
      ),
    );
  }

  void showAddAlertDialog(BuildContext context, CalificacionesBloc bloc) {
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

class CargandoDBWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
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
    return Center(child: BotonOrdenamiento(bloc: bloc));
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
    var bloc = context.watch<CalificacionesBloc>();
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
        trailing: bloc.indice == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: TextFieldCalificar(alumno: alumno),
                  ),
                  BotonEliminarAlumno(alumno: alumno)
                ],
              )
            : Text(
                bloc.calificaciones[alumno].toString(),
                style: const TextStyle(fontSize: 15),
              ),
        style: ListTileStyle.list,
      ),
    );
  }
}

class BotonEliminarAlumno extends StatelessWidget {
  final String alumno;

  const BotonEliminarAlumno({
    super.key,
    required this.alumno,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return BlocProvider.value(
                value: BlocProvider.of<CalificacionesBloc>(context),
                child: AlertConfirmacionEliminar(alumno: alumno),
              );
            },
          );
        },
        icon: const Icon(Icons.remove_circle_outline));
  }
}

class TextFieldCalificar extends StatelessWidget {
  final String alumno;
  const TextFieldCalificar({
    super.key,
    required this.alumno,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController calificarAlumno = TextEditingController();
    var bloc = context.watch<CalificacionesBloc>();
    calificarAlumno.text = bloc.calificaciones[alumno].toString();
    return TextField(
      controller: calificarAlumno,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: const InputDecoration(
          border: OutlineInputBorder(), contentPadding: EdgeInsets.all(0.0)),
      onChanged: (_) {
        if (calificarAlumno.text == "") calificarAlumno.text = "0";
        int valueEntero = int.parse(calificarAlumno.text);
        calificarAlumno.text = valueEntero.toString();
        if (valueEntero > 100) {
          calificarAlumno.text = "100";
          valueEntero = 100;
        }
        context
            .read<CalificacionesBloc>()
            .add(Calificar(calificacion: valueEntero, alumno: alumno));
      },
    );
  }
}

class AlertConfirmacionEliminar extends StatelessWidget {
  const AlertConfirmacionEliminar({
    super.key,
    required this.alumno,
  });

  final String alumno;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("¿Estás seguro de eliminar a $alumno?"),
      content: Text("El alumno $alumno será permanentemente eliminado"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar")),
        TextButton(
            onPressed: () {
              context
                  .read<CalificacionesBloc>()
                  .add(EliminarAlumno(nombre: alumno));
              Navigator.of(context).pop();
            },
            child: const Text("Continuar"))
      ],
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
