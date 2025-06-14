import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/edit_address_page.dart';
import 'package:nicoya_now/app/interface/Widgets/custumer_modify_info.dart';
import 'package:nicoya_now/app/interface/Widgets/user_bottom_bar_customer.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/features/auth/presentation/pages/driver_register_done.dart';
import 'package:nicoya_now/app/features/auth/presentation/pages/merchant_register_done.dart';
import 'package:nicoya_now/app/features/auth/presentation/pages/select_user_role_page.dart';
import 'package:nicoya_now/app/features/auth/presentation/pages/role_form_page.dart';
import 'package:nicoya_now/app/features/auth/presentation/pages/add_role_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/add_product_merchant.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/edit_product_merchant.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/home_merchant_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_settings_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_step_business.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_step_owner.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_step_password.dart';
import 'package:nicoya_now/app/features/order/presentation/pages/carrito_page.dart';
import 'package:nicoya_now/app/features/order/presentation/pages/pago_page.dart';
import 'package:nicoya_now/app/features/driver/presentation/pages/order_details_page.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/presentation/pages/merchant_public_products_page.dart';
import 'package:nicoya_now/app/features/products/presentation/pages/search_filter.dart';
import 'package:nicoya_now/app/interface/Forms/ClientForm.dart';
import 'package:nicoya_now/app/interface/Forms/DeliverForm1.dart';
import 'package:nicoya_now/app/interface/Forms/DeliverForm2.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/splash_ft1.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/splash_ft2.dart';
import 'package:nicoya_now/app/interface/SplashWidgets/splash_ft3.dart';
import 'package:nicoya_now/app/features/products/presentation/pages/food_filter.dart';
import 'package:nicoya_now/app/interface/Widgets/app_start_navigation.dart';
import 'package:nicoya_now/app/interface/Widgets/bottom_navigator.dart';
import 'package:nicoya_now/app/interface/Widgets/first_time_in.dart';
import 'package:nicoya_now/app/interface/Widgets/home_page.dart';
import 'package:nicoya_now/app/features/products/presentation/pages/home_food.dart';
import 'package:nicoya_now/app/interface/Widgets/LoginPage.dart';
import 'package:nicoya_now/app/interface/Widgets/ForgotPasswordPage.dart';
import 'package:nicoya_now/app/interface/Widgets/ResetPasswordWithCodePage.dart';
import 'package:nicoya_now/app/interface/Widgets/order_succes.dart';
import 'package:nicoya_now/app/features/products/presentation/pages/product_detail.dart';
import 'package:nicoya_now/app/interface/Widgets/register_user.dart';
import 'package:nicoya_now/app/interface/Widgets/select_type_account.dart';
import 'package:nicoya_now/app/features/admin/presentation/pages/home_admin_page.dart';
// Usando la version refactorizada del home_driver_page
import 'package:nicoya_now/app/features/driver/presentation/pages/home_driver_page_refactored.dart';

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
      // No necesitamos pasar el tipo de cuenta inicialmente
      return const Home(accountType: null);
    },    Routes.login_page: (context) {
      return const LoginPage(accountType: null);
    },    Routes.forgotPassword: (context) => const ForgotPasswordPage(),
    Routes.resetByCode: (context) {
      final email = ModalRoute.of(context)!.settings.arguments as String;
      return ResetPasswordWithCodePage(email: email);
    },

    Routes.register_user_page: (context) => const RegisterUser(),
    Routes.splashFT1: (context) => const SplashFT1(),
    Routes.splashFT2: (context) => const SplashFT2(),
    Routes.splashFT3: (context) => const SplashFT3(),
    Routes.order_Success: (context) => const OrderSucces(),
    Routes.client_Form: (context) => const ClientForm(),
    Routes.deliver_Form1: (context) => const DeliverForm1(),
    Routes.deliver_Form2: (context) => const DeliverForm2(),
    Routes.driverPending: (context) => const DriverPendingPage(),    Routes.merchantPending: (context) => const MerchantPendingPage(),    Routes.home_food: (context) => const HomeFood(),
    Routes.home_merchant: (context) => const HomeMerchantPage(),
    Routes.home_driver: (context) => const HomeDriverPage(),    Routes.driver_order_details: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == null) {
        // Handle the case where no arguments are passed
        throw Exception('Order details page requires order arguments');
      }
      final order = args as Map<String, dynamic>;
      return OrderDetailsPage(order: order);
    },
    Routes.merchantStepBusiness: (context) => const MerchantStepBusiness(),
    Routes.merchantStepOwner: (context) => const MerchantStepOwner(),
    Routes.merchantStepPassword: (context) => const MerchantStepPassword(),
    Routes.merchantSettings: (context) => const MerchantSettingsPage(),
    Routes.merchantPublicProducts:
        (context) => const MerchantPublicProductsPage(),    Routes.addProduct: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == null) {
        throw Exception('Add product page requires merchant ID argument');
      }
      final merchantId = args as String;
      return AddProductPage(merchantId: merchantId);
    },
    Routes.editProduct: (context) {
      final product = ModalRoute.of(context)!.settings.arguments as Product;
      return EditProductPage(product: product);
    },
    Routes.product_Detail: (context) => const ProductDetail(),
    Routes.home_admin: (context) => const HomeAdminPage(),
    Routes.food_filter: (context) => const FoodFilter(),
    Routes.searchFilter: (context) => const SearchFilter(),
    Routes.clientNav: (context) => const BottomNavigator(),
    Routes.isFirstTime: (context) => const FirstTimeIn(),
    Routes.appStartNavigation: (context) => const AppStartNavigation(),
    Routes.selectUserRole: (context) => const SelectUserRolePage(),    Routes.roleFormPage: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == null) {
        throw Exception('Role form page requires role type argument');
      }
      final argsMap = args as Map<String, dynamic>;
      final roleType = argsMap['roleType'] as RoleType;
      final isAddingRole = argsMap['isAddingRole'] as bool? ?? false;

      return RoleFormPage(roleType: roleType, isAddingRole: isAddingRole);
    },
    Routes.addRolePage: (context) => const AddRolePage(),
    Routes.carrito: (context) => const Carrito(),
    Routes.pago: (context) => const Pago(),
    Routes.UserBottomBarCustomer: (context) => const UserBottomBarCustomer(),
    Routes.modifyCustomerInfo: (context) => const CustumerModifyInfo(),
    Routes.editAddress: (context) {
      final addressId = ModalRoute.of(context)!.settings.arguments as String;
      return EditAddressPage(addressId: addressId);
    },
  };
}
