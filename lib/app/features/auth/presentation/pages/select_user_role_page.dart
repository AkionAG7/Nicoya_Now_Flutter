import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectUserRolePage extends StatefulWidget {
  const SelectUserRolePage({super.key});

  @override
  State<SelectUserRolePage> createState() => _SelectUserRolePageState();
}

class _SelectUserRolePageState extends State<SelectUserRolePage> {
  bool _isLoading = true;
  List<String> _availableRoles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    
    // Si ya hay roles disponibles, usarlos
    if (authController.availableRoles.isNotEmpty) {
      setState(() {
        _availableRoles = authController.availableRoles;
        _isLoading = false;
      });
      return;
    }
    
    // Si no hay roles, cargarlos directamente
    try {
      final roleService = RoleService(Supabase.instance.client);
      final roles = await roleService.getUserRoles();
      setState(() {
        _availableRoles = roles;
        _isLoading = false;
      });
    } catch (e) {
      //ignore: avoid_print
      print('Error cargando roles: $e');
      setState(() {
        _availableRoles = ['customer']; // Rol predeterminado como fallback
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
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
                _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffd72a23),
                    ),
                  )
                : _availableRoles.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron roles disponibles',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: _availableRoles.map((role) => _buildRoleCard(context, role)).toList(),
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
            Navigator.of(context).pushReplacementNamed(Routes.home_driver);
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
