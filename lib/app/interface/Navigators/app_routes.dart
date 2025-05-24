import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/pages/driver_register_done.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_step_business.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_step_owner.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_step_password.dart';
import 'package:nicoya_now/app/interface/Forms/ClientForm.dart';
import 'package:nicoya_now/app/interface/Forms/DeliverForm1.dart';
import 'package:nicoya_now/app/interface/Forms/DeliverForm2.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/SplashFT1.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/SplashFT2.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/SplashFT3.dart';
import 'package:nicoya_now/app/interface/Widgets/Home.dart';
import 'package:nicoya_now/app/interface/Widgets/HomeFood.dart';
import 'package:nicoya_now/app/interface/Widgets/LoginPage.dart';
import 'package:nicoya_now/app/interface/Widgets/OrderSucces.dart';
import 'package:nicoya_now/app/interface/Widgets/RegisterUser.dart';
import 'package:nicoya_now/app/interface/Widgets/SelectTypeAccount.dart';

import 'routes.dart';

/*
Tutorial expres de como usar este archivo
Es un get con tipo map en el cual se importa la ruta.nombre dado en routes.dart
y se pasa el contexto de la app y el widget que se va a mostrar
al ser una ruta fija que no se va a modifiar al widget se le pone const
*/
Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.selecctTypeAccount: (context) => const SelectTypeAccount(),

    Routes.preLogin: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as AccountType?;
      return Home(accountType: args);
    },

    Routes.login_page: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as AccountType?;
      return LoginPage(accountType: args);
    },
    
    Routes.register_user_page: (context) => const RegisterUser(),
    Routes.splashFT1: (context) => const SplashFT1(),
    Routes.splashFT2: (context) => const SplashFT2(),
    Routes.splashFT3: (context) => const SplashFT3(),
    Routes.order_Success: (context) => const OrderSucces(),
    Routes.client_Form: (context) => const ClientForm(),
    Routes.deliver_Form1: (context) => const DeliverForm1(),
    Routes.deliver_Form2: (context) => const DeliverForm2(),
    Routes.driverPending: (context) => const DriverPendingPage(),
    Routes.home_food: (context) => const HomeFood(),
       Routes.merchantStepBusiness : (context) => const MerchantStepBusiness(),
    Routes.merchantStepOwner    : (context) => const MerchantStepOwner(),
    Routes.merchantStepPassword : (context) => const MerchantStepPassword(),
  };
}
