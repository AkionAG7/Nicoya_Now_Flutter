import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

enum AccountType { repartidor, comercio, cliente }

class SelectTypeAccount extends StatefulWidget {
  const SelectTypeAccount({Key? key}) : super(key: key);

  @override
  _SelectTypeAccountState createState() => _SelectTypeAccountState();
}

class _SelectTypeAccountState extends State<SelectTypeAccount> {  void _showLoginPrompt(BuildContext context, String roleSlug, String formRoute) {
    final authController = Provider.of<AuthController>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Ya tienes una cuenta?'),
        content: Text('¿Deseas iniciar sesión para agregar este rol a tu cuenta existente o crear una cuenta nueva?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar diálogo
              
              // Ir a login con el rol seleccionado
              final result = await Navigator.pushNamed(
                context,
                Routes.login_page,
                arguments: {'selectedRole': roleSlug}
              );
                // Si el login fue exitoso, agregar el nuevo rol
              if (result == true) {
                try {
                  // Verificar si el usuario ya tiene este rol
                  if (await authController.hasRole(roleSlug)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ya tienes este rol asignado')),
                    );
                    return;
                  }
                  
                  await authController.addRole(roleSlug);
                  await authController.loadUserRoles();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('¡Rol agregado con éxito!')),
                  );
                  
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.home_food,
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Iniciar Sesión'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffd72a23),
            ),
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              // Ir al formulario de registro
              Navigator.pushNamed(context, formRoute);
            },
            child: Text(
              'Crear Cuenta Nueva',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
      ),

      body: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  NicoyaNowIcons.nicoyanow,
                  size: 250,
                  color: const Color(0xffd72a23),
                ),
              ),
              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xffd72a23),
                          width: 2,
                        ),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: const Color(0xffffffff),
                      ),                      onPressed: () => _showLoginPrompt(context, 'driver', Routes.deliver_Form1),
                      child: Column(
                        children: [
                          Image.asset(
                            'lib/app/interface/public/Repartidor.png',
                            width: 120,
                            height: 120,
                          ),
                          Text(
                            'Repartidor',
                            style: TextStyle(color: const Color(0xffd72a23)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 40),

                  SizedBox(
                    width: 140,
                    height: 140,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xffd72a23),
                          width: 2,
                        ),
                        shape: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: const Color(0xffffffff),
                      ),                      onPressed: () => _showLoginPrompt(context, 'merchant', Routes.merchantStepBusiness),
                      child: Column(
                        children: [
                          Image.asset(
                            'lib/app/interface/public/Comercio.png',
                            width: 120,
                            height: 120,
                          ),
                          Text(
                            'Comercio',
                            style: TextStyle(color: const Color(0xffd72a23)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40),
              SizedBox(
                width: 140,
                height: 140,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: BorderSide(color: const Color(0xffd72a23), width: 2),
                    shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: const Color(0xffffffff),
                  ),                  onPressed: () => _showLoginPrompt(context, 'client', Routes.client_Form),
                  child: Column(
                    children: [
                      Image.asset(
                        'lib/app/interface/public/SplashFT2.png',
                        width: 120,
                        height: 120,
                      ),
                      Text(
                        'Cliente',
                        style: TextStyle(color: const Color(0xffd72a23)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
