import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 30),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xfff10027),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const SizedBox(
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
                                child: AspectRatio(
                                  aspectRatio: 16/9,
                                  child: Image.asset(
                                    'lib/app/interface/Public/SplashFT3.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Entrega a domicilio',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xffd72a23),
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 20),

                              const Text(
                                'Disfrute de una entrega rápida y fluida en su puerta.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xff000000), fontSize: 20),
                              ),

                              const SizedBox(height: 40),

                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.circle_outlined),
                                  SizedBox(width: 5),
                                  Icon(Icons.circle_outlined),
                                  SizedBox(width: 5),
                                  Icon(Icons.circle),
                                ],
                              ),
                            ],
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, Routes.preLogin);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffd72a23),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: const Text(
                                  'Continuar',
                                  style: TextStyle(fontSize: 24, color: Colors.white),
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
            ),
          ),
        ),
      ),
    );
  }
}
