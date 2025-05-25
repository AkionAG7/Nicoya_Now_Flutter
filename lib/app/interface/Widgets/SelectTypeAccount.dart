import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/RoleRegistrationFlow.dart';

enum AccountType { repartidor, comercio, cliente }

class SelectTypeAccount extends StatefulWidget {
  const SelectTypeAccount({Key? key}) : super(key: key);

  @override
  State<SelectTypeAccount> createState() => _SelectTypeAccountState();
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
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Icon(NicoyaNowIcons.nicoyanow,
                  size: 250, color: const Color(0xffd72a23)),
              const SizedBox(height: 40),

              /* ---------- Fila Repartidor / Comercio ---------- */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [                  _roleButton(
                    label: 'Repartidor',
                    asset: 'lib/app/interface/public/Repartidor.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoleRegistrationFlow(
                          roleSlug: 'driver',
                          roleTitle: 'Repartidor',
                          registrationRoute: Routes.deliver_Form1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),                  _roleButton(
                    label: 'Comercio',
                    asset: 'lib/app/interface/public/Comercio.png',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoleRegistrationFlow(
                          roleSlug: 'merchant',
                          roleTitle: 'Comercio',
                          registrationRoute: Routes.merchantStepBusiness,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /* ---------- Botón Cliente ---------- */              _roleButton(
                label: 'Cliente',
                asset: 'lib/app/interface/public/SplashFT2.png',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoleRegistrationFlow(
                      roleSlug: 'client',
                      roleTitle: 'Cliente',
                      registrationRoute: Routes.client_Form,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  /* ─────────────────────── Helper widget ─────────────────────── */
  Widget _roleButton({
    required String label,
    required String asset,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: 140,
        height: 140,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xffd72a23), width: 2),
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(asset, width: 120, height: 120),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Color(0xffd72a23))),
            ],
          ),
        ),
      );
}
