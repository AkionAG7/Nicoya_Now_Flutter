import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Selecciona el rol con el que deseas ingresar:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: availableRoles.length,
                  itemBuilder: (context, index) {
                    final role = availableRoles[index];
                    return _buildRoleCard(context, role);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleCard(BuildContext context, String role) {
    String roleTitle;
    String roleDescription;
    IconData roleIcon;
    
    switch (role) {
      case 'customer':
        roleTitle = 'Cliente';
        roleDescription = 'Accede como cliente para realizar pedidos';
        roleIcon = Icons.person;
        break;
      case 'driver':
        roleTitle = 'Conductor';
        roleDescription = 'Accede como repartidor para gestionar entregas';
        roleIcon = Icons.delivery_dining;
        break;
      case 'merchant':
        roleTitle = 'Comercio';
        roleDescription = 'Accede como comercio para gestionar tus productos';
        roleIcon = Icons.store;
        break;
      default:
        roleTitle = role.toUpperCase();
        roleDescription = 'Accede con este rol';
        roleIcon = Icons.account_circle;
    }
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: InkWell(
        onTap: () => _selectRole(context, role),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                radius: 30,
                child: Icon(
                  roleIcon,
                  size: 30,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roleTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      roleDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
  
  void _selectRole(BuildContext context, String role) {
    // In a real app, you would navigate to the appropriate home page
    // or dashboard based on the selected role
    Navigator.of(context).pushReplacementNamed('/home');
    
    // You could also store the selected role in preferences or
    // update the default role in the database
  }
}
