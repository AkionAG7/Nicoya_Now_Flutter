import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class RoleRegistrationFlow extends StatefulWidget {
  final String roleSlug;
  final String roleTitle;
  final String registrationRoute;

  const RoleRegistrationFlow({
    Key? key,
    required this.roleSlug,
    required this.roleTitle,
    required this.registrationRoute,
  }) : super(key: key);

  @override
  State<RoleRegistrationFlow> createState() => _RoleRegistrationFlowState();
}

class _RoleRegistrationFlowState extends State<RoleRegistrationFlow> {
  bool _isCheckingUser = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro como ${widget.roleTitle}'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xffd72a23),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add,
              size: 100,
              color: Color(0xffd72a23),
            ),
            SizedBox(height: 20),
            Text(
              '¿Ya tienes una cuenta?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xffd72a23),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Si ya tienes una cuenta como cliente, repartidor o comercio, '
              'puedes usar la misma cuenta para agregar el rol de ${widget.roleTitle.toLowerCase()}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 40),
            
            // Botón para usuarios existentes
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffd72a23),
                ),
                onPressed: _isCheckingUser ? null : () => _handleExistingUser(),
                child: _isCheckingUser
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Ya tengo una cuenta - Agregar rol',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Botón para nuevos usuarios
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xffd72a23), width: 2),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, widget.registrationRoute);
                },
                child: Text(
                  'Crear cuenta nueva',
                  style: TextStyle(color: Color(0xffd72a23), fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  Future<void> _handleExistingUser() async {
    setState(() {
      _isCheckingUser = true;
    });

    try {
      // Mostrar formulario de login especializado para agregar rol
      final result = await showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _AddRoleLoginDialog(
          roleSlug: widget.roleSlug,
          roleTitle: widget.roleTitle,
        ),
      );

      if (result == true) {
        // Éxito completo - ir a la pantalla principal
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Rol de ${widget.roleTitle} agregado con éxito!')),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home_food,
          (route) => false,
        );
      } else if (result == 'needs_data') {
        // Éxito parcial - necesita completar datos específicos del rol
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rol agregado. Completando datos del ${widget.roleTitle}...')),
        );

        // Redireccionar al formulario específico con isAddingRole = true
        await _redirectToRoleForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isCheckingUser = false;
      });
    }
  }
  Future<void> _redirectToRoleForm() async {
    // Redireccionar al formulario específico del rol con isAddingRole = true
    switch (widget.roleSlug) {
      case 'merchant':
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.merchantStepBusiness,
          (route) => false,
          arguments: {'isAddingRole': true},
        );
        break;
      case 'delivery':
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.deliver_Form1,
          (route) => false,
          arguments: {'isAddingRole': true},
        );
        break;
      case 'client':
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.client_Form,
          (route) => false,
          arguments: {'isAddingRole': true},
        );
        break;
      default:
        // Si no hay formulario específico, ir a home
        Navigator.pushNamedAndRemoveUntil(
          context,
          Routes.home_food,
          (route) => false,
        );
    }
  }
}

// Diálogo especializado para login y agregar rol
class _AddRoleLoginDialog extends StatefulWidget {
  final String roleSlug;
  final String roleTitle;

  const _AddRoleLoginDialog({
    required this.roleSlug,
    required this.roleTitle,
  });

  @override
  State<_AddRoleLoginDialog> createState() => _AddRoleLoginDialogState();
}

class _AddRoleLoginDialogState extends State<_AddRoleLoginDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _hidePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar rol de ${widget.roleTitle}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ingresa las credenciales de tu cuenta existente:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu email';
                }
                if (!value.contains('@')) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _hidePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingresa tu contraseña';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleAddRole,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffd72a23),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Agregar rol',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
  Future<void> _handleAddRole() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authController = context.read<AuthController>();
      
      final success = await authController.addRoleToExistingUser(
        _emailController.text.trim(),
        _passwordController.text,
        widget.roleSlug,
      );

      if (success) {
        // Verificar si necesita completar datos específicos del rol
        final needsRoleData = await _checkIfNeedsRoleSpecificData();
        
        if (needsRoleData) {
          // Cerrar el diálogo con éxito parcial (necesita completar datos)
          Navigator.of(context).pop('needs_data');
        } else {
          // Todo completo, cerrar con éxito total
          Navigator.of(context).pop(true);
        }
      } else {
        setState(() {
          _errorMessage = authController.errorMessage ?? 'Error al agregar el rol';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Verificar si el usuario necesita completar datos específicos del rol
  Future<bool> _checkIfNeedsRoleSpecificData() async {
    // Por ahora, asumimos que siempre necesita completar datos específicos del rol
    // En el futuro, esto podría consultar la base de datos para verificar
    // si ya tiene datos completos para este rol específico
    
    switch (widget.roleSlug) {
      case 'merchant':
        // Para merchant, siempre necesita configurar datos del negocio
        return true;
      case 'delivery':
        // Para delivery, podría necesitar completar datos adicionales
        return true;
      case 'client':
        // Para client, normalmente no necesita datos adicionales
        return false;
      default:
        return true;
    }
  }
}
