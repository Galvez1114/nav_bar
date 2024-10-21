import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nav_bar/calificaciones_bloc.dart';
import 'package:nav_bar/db/db_constantes.dart';
import 'package:nav_bar/modelos/modelos.dart';
import 'package:nav_bar/pantalla_detalles_alumno.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        create: (context) => CalificacionesBloc()..add(ExtractDBData()),
        child: BlocBuilder<CalificacionesBloc, EstadoCalificaciones>(
          builder: (context, state) {
            var bloc = context.watch<CalificacionesBloc>();
            return Scaffold(
              appBar: AppBar(
                title: const Text('Calificaciones'),
                backgroundColor: const Color.fromRGBO(130, 139, 182, 1),
                actions: [SortSwitchesWidget(bloc: bloc)],
              ),
              bottomNavigationBar: BarraNavegacion(indice: bloc.indice),
              body: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: switch (bloc.state) {
                        EstadoInicial() => const CargandoDBWidget(),
                        _ => switch (bloc.indice) {
                            0 => ListaRevision(
                                alumnos: bloc.ordenado.estaOrdenada()
                                    ? bloc.ordenado.alumnosOrdenado
                                    : bloc.alumnos.revision),
                            1 => ListaAprobados(
                                alumnos: bloc.ordenado.estaOrdenada()
                                    ? bloc.ordenado.alumnosOrdenado
                                    : bloc.alumnos.aprobados),
                            2 => ListaReprobado(
                                alumnos: bloc.ordenado.estaOrdenada()
                                    ? bloc.ordenado.alumnosOrdenado
                                    : bloc.alumnos.reprobados),
                            _ => const Advertencia(),
                          }
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: Text(
                      "Promedio general: ${bloc.promedioGeneral}",
                      style: TextStyle(
                          color: switch (bloc.promedioGeneral) {
                        > 70 => Colors.green,
                        _ => Colors.red
                      }),
                    ),
                  ),
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
    TextEditingController calificacionController = TextEditingController();
    // set up the button
    Widget agregarButton = TextButton(
      style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.blue)),
      child: const Text(
        "Agregar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        context.read<CalificacionesBloc>().add(AgregarAlumno(bloc.indice,
            alumno: Alumno(
                name: alumnoController.text,
                estadoCalificacion: estadoRevision,
                calificacion: int.parse(calificacionController.text))));
        Navigator.of(context).pop();
      },
    );

    Widget cancelarButton = TextButton(
      style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.red)),
      child: const Text(
        "Cancelar",
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget nombreAlumno = TextField(
      controller: alumnoController,
      decoration: const InputDecoration(label: Text("Ingresar nombre alumno")),
    );
    Widget calificacionAlumno = TextField(
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
        FilteringTextInputFormatter.allow(RegExp(r'^(100|[1-9]?[0-9])$')),
      ],
      controller: calificacionController,
      decoration:
          const InputDecoration(label: Text("Ingresar calificación alumno")),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Agregar alumno"),
      content: Column(
        children: [nombreAlumno, calificacionAlumno],
      ),
      actions: [cancelarButton, agregarButton],
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
  const CargandoDBWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

class SortSwitchesWidget extends StatelessWidget {
  const SortSwitchesWidget({
    super.key,
    required this.bloc,
  });

  final CalificacionesBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      children: [
        SwitchAlfabeticoWidget(bloc: bloc),
        SwitchDescendenteWidget(bloc: bloc)
      ],
    ));
  }
}

class SwitchDescendenteWidget extends StatelessWidget {
  final CalificacionesBloc bloc;

  const SwitchDescendenteWidget({
    super.key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
              value: bloc.ordenado.ordenadoDescendente,
              onChanged: (value) {
                context
                    .read<CalificacionesBloc>()
                    .add(OrdenarDescendente(value));
              }),
          const Text("Ordenar por calificación")
        ],
      ),
    );
  }
}

class SwitchAlfabeticoWidget extends StatelessWidget {
  final CalificacionesBloc bloc;

  const SwitchAlfabeticoWidget({
    super.key,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
              value: bloc.ordenado.ordenadoAlfabetico,
              onChanged: (value) {
                context
                    .read<CalificacionesBloc>()
                    .add(OrdenarAlfabetico(value));
              }),
          const Text("Ordenar alfabéticamente")
        ],
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
  final List<Alumno> alumnos;

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
      BuildContext context, DismissDirection direction, Alumno alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(
          MandarARevision(alumno: alumno, fromList: TiposListas.reprobados));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(
          MandarAAprobados(alumno: alumno, fromList: TiposListas.reprobados));
    }
  }
}

class ListaRevision extends StatelessWidget {
  final List<Alumno> alumnos;
  const ListaRevision({super.key, required this.alumnos});

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
      BuildContext context, DismissDirection direction, Alumno alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(
          MandarAAprobados(alumno: alumno, fromList: TiposListas.revision));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(
          MandarAReprobados(alumno: alumno, fromList: TiposListas.revision));
    }
  }
}

class ListaAprobados extends StatelessWidget {
  final List<Alumno> alumnos;
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
      BuildContext context, DismissDirection direction, Alumno alumno) {
    if (direction == DismissDirection.startToEnd) {
      context.read<CalificacionesBloc>().add(
          MandarARevision(alumno: alumno, fromList: TiposListas.aprobados));
    }
    if (direction == DismissDirection.endToStart) {
      context.read<CalificacionesBloc>().add(
          MandarAReprobados(alumno: alumno, fromList: TiposListas.aprobados));
    }
  }
}

class Elemento extends StatelessWidget {
  final Alumno alumno;
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
        onLongPress: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PantallaDetallesAlumno(
                      nombre: alumno.name,
                      calificacion: alumno.calificacion,
                      estado: alumno.estadoCalificacion)));
        },
        title: Text(alumno.name),
        trailing: bloc.indice == 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextCalificacion(alumno: alumno),
                  //TextFieldCalificar(alumno: alumno),
                  BotonEliminarAlumno(alumno: alumno),
                  BotonEditarCalificacion(
                    alumno: alumno,
                  )
                ],
              )
            : Text(
                alumno.calificacion.toString(),
                style: const TextStyle(fontSize: 15),
              ),
        style: ListTileStyle.list,
      ),
    );
  }
}

class TextCalificacion extends StatelessWidget {
  final Alumno alumno;
  const TextCalificacion({super.key, required this.alumno});
  @override
  Widget build(BuildContext context) {
    double pantallaWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.only(right: pantallaWidth * 0.4),
      child: Text(
        '${alumno.calificacion}',
        style: const TextStyle(fontSize: 15),
      ),
    );
  }
}

class BotonEliminarAlumno extends StatelessWidget {
  final Alumno alumno;

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
        icon: const Icon(
          Icons.remove_circle,
          color: Colors.red,
        ));
  }
}

class BotonEditarCalificacion extends StatelessWidget {
  final Alumno alumno;
  const BotonEditarCalificacion({super.key, required this.alumno});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) {
              return BlocProvider.value(
                value: BlocProvider.of<CalificacionesBloc>(context),
                child: AlertEditarCalificacion(alumno: alumno),
              );
            },
          );
        },
        icon: const Icon(
          Icons.edit_document,
          color: Colors.blue,
        ));
  }
}

class AlertEditarCalificacion extends StatelessWidget {
  final Alumno alumno;
  const AlertEditarCalificacion({super.key, required this.alumno});
  @override
  Widget build(BuildContext context) {
    TextEditingController controllerCalificacion = TextEditingController();
    return AlertDialog(
      title: Text('Editar la calificación de ${alumno.name}'),
      content: TextField(
        controller: controllerCalificacion,
        decoration: InputDecoration(hintText: '${alumno.calificacion}'),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
          FilteringTextInputFormatter.allow(RegExp(r'^(100|[1-9]?[0-9])$')),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              context.read<CalificacionesBloc>().add(Calificar(
                  calificacion: int.parse(controllerCalificacion.text),
                  alumno: alumno));
              Navigator.of(context).pop();
            },
            child: const Text('Confirmar')),
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'))
      ],
    );
  }
}

class AlertConfirmacionEliminar extends StatelessWidget {
  final Alumno alumno;

  const AlertConfirmacionEliminar({
    super.key,
    required this.alumno,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("¿Estás seguro de eliminar a ${alumno.name}?"),
      content: Text("El alumno ${alumno.name} será permanentemente eliminado"),
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
                  .add(EliminarAlumno(alumno: alumno));
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
        elevation: 10,
        indicatorColor: const Color.fromARGB(255, 75, 94, 158),
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
