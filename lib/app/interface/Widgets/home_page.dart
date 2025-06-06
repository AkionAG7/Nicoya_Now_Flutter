import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/select_type_account.dart';

class Home extends StatelessWidget {
  final AccountType? accountType;
  const Home({super.key, required this.accountType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xfff10027),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Icon(
                  NicoyaNowIcons.nicoyanow,
                  size: 60,
                  color: Color(0xfff8bb08),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  NicoyaNowIcons.nicoyanow,
                  size: 400,
                  color: Color(0xffd72a23),
                ),
                ElevatedButton(
                  onPressed:
                      () => Navigator.pushNamed(context, Routes.login_page),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                    backgroundColor: Color(0xffd72a23),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(width: 100),
                      Icon(
                        NicoyaNowIcons.flechaderecha,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    // Dirigir al usuario a la selección del tipo de cuenta
                    Navigator.pushNamed(context, Routes.selecctTypeAccount);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 30),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Color(0xffd72a23), width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Registrarse',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xffd72a23),
                        ),
                      ),
                      SizedBox(width: 118),
                      Icon(
                        NicoyaNowIcons.flechaderecha,
                        color: Color(0xffd72a23),
                        size: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
