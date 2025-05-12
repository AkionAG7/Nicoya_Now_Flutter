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
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.preLogin, arguments: AccountType.repartidor);
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
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.preLogin, arguments: AccountType.comercio);
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
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.preLogin, arguments: AccountType.cliente);
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
