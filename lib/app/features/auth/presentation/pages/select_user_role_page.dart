import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectUserRolePage extends StatelessWidget {
  const SelectUserRolePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final availableRoles = authController.availableRoles;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Rol'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona el rol con el que deseas ingresar:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffd72a23),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                runSpacing: 20,
                children: availableRoles.map((role) => _buildRoleCard(context, role)).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
    Widget _buildRoleCard(BuildContext context, String role) {
    String roleTitle;
    String imageAsset;
    
    switch (role) {
      case 'customer':
        roleTitle = 'Cliente';
        imageAsset = 'lib/app/interface/Public/SplashFT2.png';
        break;
      case 'driver':
        roleTitle = 'Repartidor';
        imageAsset = 'lib/app/interface/Public/Repartidor.png';
        break;
      case 'merchant':
        roleTitle = 'Comercio';
        imageAsset = 'lib/app/interface/Public/Comercio.png';
        break;
      default:
        roleTitle = role.toUpperCase();
        imageAsset = 'lib/app/interface/Public/SplashFT2.png';
    }
    
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
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
          onPressed: () => _selectRole(context, role),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageAsset,
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 8),
              Text(
                roleTitle,
                style: TextStyle(color: const Color(0xffd72a23)),
              ),
            ],
          ),
        ),
      ),
    );
  }
    void _selectRole(BuildContext context, String role) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );
      
      // Establecer el rol seleccionado como predeterminado
      final roleService = RoleService(Supabase.instance.client);
      await roleService.setDefaultRole(role);
      
      // Navegar a la página apropiada según el rol
      if (context.mounted) {
        Navigator.of(context).pop(); // Cerrar diálogo de carga
        
        switch (role) {
          case 'customer':
            Navigator.of(context).pushReplacementNamed(Routes.home_food);
            break;
          case 'driver':
            // TODO: Implementar navegación a página de repartidor
            Navigator.of(context).pushReplacementNamed(Routes.home_food);
            break;
          case 'merchant':
            Navigator.of(context).pushReplacementNamed(Routes.home_merchant);
            break;
          default:
            Navigator.of(context).pushReplacementNamed(Routes.home_food);
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga y mostrar error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar de rol: ${e.toString()}')),
        );
      }
    }
  }
}
