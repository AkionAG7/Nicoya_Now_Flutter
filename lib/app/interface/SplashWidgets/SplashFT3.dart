import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class SplashFT3 extends StatelessWidget {
  const SplashFT3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Center(
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

                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 270,
                    child: Image.asset(
                      'lib/app/interface/public/SplashFT3.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Entrega a domicilio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffd72a23),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Disfrute de una entrega rápida y fluida en su puerta.',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Color(0xff000000), fontSize: 20),
                ),

                SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle_outlined),
                    SizedBox(width: 5),
                    Icon(Icons.circle_outlined),
                    SizedBox(width: 5),
                    Icon(Icons.circle),
                  ],
                ),

                SizedBox(height: 20),

                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.selecctTypeAccount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffd72a23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Continuar',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
