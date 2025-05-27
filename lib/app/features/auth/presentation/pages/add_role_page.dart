import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';

class AddRolePage extends StatefulWidget {
  const AddRolePage({Key? key}) : super(key: key);

  @override
  State<AddRolePage> createState() => _AddRolePageState();
}

class _AddRolePageState extends State<AddRolePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  RoleType? _selectedRoleType;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar nuevo rol'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Text(
                  'Para agregar un nuevo rol a tu cuenta, primero verifica tu identidad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              
              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 15),
              
              // Password field
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
                // Role selection
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: Text(
                  'Selecciona el rol que quieres agregar:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              _buildRoleSelection(),
              const SizedBox(height: 30),
              
              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyAndContinue,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONTINUAR'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRoleSelection() {
    return Column(
      children: [
        // Driver role option
        _buildRoleOption(
          RoleType.driver,
          'Conductor',
          'Regístrate como conductor para entregar pedidos',
          Icons.delivery_dining,
        ),
        
        // Merchant role option
        _buildRoleOption(
          RoleType.merchant,
          'Comerciante',
          'Regístrate como comercio para vender productos',
          Icons.store,
        ),
        
        // Customer role option
        _buildRoleOption(
          RoleType.customer,
          'Cliente',
          'Regístrate como cliente para hacer pedidos',
          Icons.person,
        ),
      ],
    );
  }
    Widget _buildRoleOption(
    RoleType roleType,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _selectedRoleType == roleType;
    
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 10),
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRoleType = roleType;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Radio<RoleType>(
                value: roleType,
                groupValue: _selectedRoleType,
                onChanged: (value) {
                  setState(() {
                    _selectedRoleType = value;
                  });
                },
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _verifyAndContinue() async {
    // Check if all fields are filled
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _selectedRoleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos y selecciona un rol'),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      // Verify credentials and check if user already has the selected role
      final success = await authController.handleRoleAdditionFlow(
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRoleType!,
      );
      
      if (!mounted) return;
        if (success) {
        // For driver role, go directly to DeliverForm1 to avoid duplicate data entry
        if (_selectedRoleType == RoleType.driver) {
          Navigator.pushNamed(
            context, 
            Routes.deliver_Form1,
            arguments: {
              'isAddingRole': true,
            },
          );
        } else {
          // For other roles, use the generic role form page
          Navigator.pushNamed(
            context, 
            Routes.roleFormPage,
            arguments: {
              'roleType': _selectedRoleType!,
              'isAddingRole': true,
            },
          );
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Error desconocido'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
