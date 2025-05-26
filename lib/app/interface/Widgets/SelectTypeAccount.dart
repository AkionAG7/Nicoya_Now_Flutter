import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

enum AccountType { repartidor, comercio, cliente }

class SelectTypeAccount extends StatefulWidget {
  const SelectTypeAccount({super.key});

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
                      ),                      onPressed: () {
                        Navigator.pushNamed(context, Routes.deliver_Form1);
                      },
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
                      ),                      onPressed: () {
                        Navigator.pushNamed(context, Routes.merchantStepBusiness);
                      },
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
                  ),                  onPressed: () {
                    _showLoginPrompt('customer');
                  },
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
