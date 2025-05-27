import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

enum AccountType { repartidor, comercio, cliente }

class SelectTypeAccount extends StatefulWidget {
  const SelectTypeAccount({Key? key}) : super(key: key);

  @override
  _SelectTypeAccountState createState() => _SelectTypeAccountState();
}

class _SelectTypeAccountState extends State<SelectTypeAccount> {
  
  /// Shows a login prompt dialog for the customer role
  void _showLoginPrompt(String roleSlug) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Iniciar Sesión'),
          content: Text('Para continuar como cliente, necesitas iniciar sesión o crear una cuenta.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login page 
                Navigator.pushNamed(context, Routes.login_page);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffd72a23),
              ),
              child: Text('Iniciar Sesión', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to client registration form
                Navigator.pushNamed(context, Routes.client_Form);
              },
              child: Text('Crear Cuenta', style: TextStyle(color: const Color(0xffd72a23))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [              // App Bar with logo
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/app/interface/Public/LogoApp.png',
                        height: 45,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Nicoya\nNow',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffd72a23),
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.addRolePage);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xffd72a23),
                      side: const BorderSide(color: Color(0xffd72a23)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Ya tengo cuenta'),
                  ),
                ],
              ),

              Center(
                child: Icon(
                  NicoyaNowIcons.nicoyanow,
                  size: 250,
                  color: const Color(0xffd72a23),
                ),
              ),
              SizedBox(height: 40),              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
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
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.deliver_Form1);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/app/interface/Public/Repartidor.png',
                            width: 100,
                            height: 100,
                          ),
                          Text(
                            'Repartidor',
                            style: TextStyle(color: const Color(0xffd72a23)),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.merchantStepBusiness);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'lib/app/interface/Public/Comercio.png',
                            width: 100,
                            height: 100,
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
              ),              SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(color: const Color(0xffd72a23), width: 2),
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: const Color(0xffffffff),
                    ),
                    onPressed: () {
                      _showLoginPrompt('customer');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/app/interface/Public/SplashFT2.png',
                          width: 100,
                          height: 100,
                        ),
                        Text(
                          'Cliente',
                          style: TextStyle(color: const Color(0xffd72a23)),
                        ),
                      ],
                    ),
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
