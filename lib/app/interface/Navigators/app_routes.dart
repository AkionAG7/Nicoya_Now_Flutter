import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/SplashFT1.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/SplashFT2.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/SplashFT3.dart';
import 'package:nicoya_now/app/interface/Widgets/Home.dart';
import 'package:nicoya_now/app/interface/Widgets/LoginPage.dart';
import 'package:nicoya_now/app/interface/Widgets/RegisterUser.dart';

import 'routes.dart';

/*
Tutorial expres de como usar este archivo
Es un get con tipo map en el cual se importa la ruta.nombre dado en routes.dart
y se pasa el contexto de la app y el widget que se va a mostrar
al ser una ruta fija que no se va a modifiar al widget se le pone const
*/
Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.first: (context) => const Home(),
    Routes.login_page: (context) => const LoginPage(),
    Routes.register_user_page: (context) => const RegisterUser(),
    Routes.splashFT1: (context) => const SplashFT1(),
    Routes.splashFT2: (context) => const SplashFT2(),
    Routes.splashFT3: (context) => const SplashFT3(),
  };
}
