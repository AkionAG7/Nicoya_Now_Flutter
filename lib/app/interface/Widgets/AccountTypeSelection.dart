import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

class AccountTypeSelection extends StatelessWidget {
  final String roleType;
  final String roleSlug;
  final String title;
  final String subtitle;
  final String imagePath;
  final String registrationRoute;

  const AccountTypeSelection({
    Key? key,
    required this.roleType,
    required this.roleSlug,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.registrationRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xffd72a23)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Registro como $roleType',
          style: TextStyle(color: Color(0xffd72a23)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 200,
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xffd72a23),
              ),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xffd72a23),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () async {
                      final authController = context.read<AuthController>();
                      
                      if (await authController.isUserRegistered()) {
                        // Si ya está registrado, solo agregar el nuevo rol
                        await authController.addRole(roleSlug);
                        
                        // Mostrar mensaje de éxito
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('¡Rol agregado con éxito!')),
                        );
                        
                        // Redirigir a la pantalla principal
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Routes.home_food,
                          (route) => false,
                        );
                      } else {
                        // Si no está registrado, ir al formulario de registro
                        Navigator.pushNamed(context, registrationRoute);
                      }
                    },
                    child: Text(
                      'Ya tengo una cuenta',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Color(0xffd72a23), width: 2),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, registrationRoute);
                    },
                    child: Text(
                      'Crear cuenta nueva',
                      style: TextStyle(color: Color(0xffd72a23), fontSize: 16),
                    ),
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
