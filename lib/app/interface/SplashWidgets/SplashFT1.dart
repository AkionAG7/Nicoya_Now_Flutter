import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class SplashFT1 extends StatefulWidget {
  const SplashFT1({super.key});

  @override
  _SplashFT1State createState() => _SplashFT1State();
}

class _SplashFT1State extends State<SplashFT1> {
  late TapGestureRecognizer _tapSkip;

  @override
  void initState() {
    super.initState();
    _tapSkip =
        TapGestureRecognizer()
          ..onTap = () {
            Navigator.pushNamed(context, Routes.preLogin);
          };
  }

  @override
  void dispose() {
    _tapSkip.dispose();
    super.dispose();
  }

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
                      'lib/app/interface/Public/SplashFT1.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Tu comida reconfortante está aquí',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xffd72a23),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20),

                Text(
                  'Pide tu comida favorita y saborea la grandeza',
                  textAlign: TextAlign.left,
                  style: TextStyle(color: Color(0xff000000), fontSize: 20),
                ),

                SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.circle),
                    SizedBox(width: 5),
                    Icon(Icons.circle_outlined),
                    SizedBox(width: 5),
                    Icon(Icons.circle_outlined),
                  ],
                ),

                SizedBox(height: 20),

                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.splashFT2);
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

                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Saltar',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    recognizer: _tapSkip,
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
