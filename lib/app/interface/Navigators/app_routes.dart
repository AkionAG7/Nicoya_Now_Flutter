import 'package:flutter/material.dart';
import '../Widgets/example.dart';
import 'routes.dart';

/*
Tutorial expres de como usar este archivo
Es un get con tipo map en el cual se importa la ruta.nombre dado en routes.dart
y se pasa el contexto de la app y el widget que se va a mostrar
al ser una ruta fija que no se va a modifiar al widget se le pone const
*/
Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.first: (context) => const HomePage()
  
  };
}
