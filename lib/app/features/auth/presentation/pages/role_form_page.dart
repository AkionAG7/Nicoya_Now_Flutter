import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';

class RoleFormPage extends StatefulWidget {
  final RoleType roleType;
  final bool
  isAddingRole; // true if adding role to existing user, false for new registration

  const RoleFormPage({
    super.key,
    required this.roleType,
    this.isAddingRole = false,
  });

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Automatic redirection for merchant and driver roles
    // We use a post-frame callback to ensure the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectToRoleForm();
    });
  }

  void _redirectToRoleForm() {
    // Immediately redirect to the appropriate form page
    if (widget.roleType == RoleType.driver) {
      Navigator.pushReplacementNamed(
        context,
        Routes.deliver_Form1,
        arguments: {'isAddingRole': widget.isAddingRole},
      );
    } else if (widget.roleType == RoleType.merchant) {
      Navigator.pushReplacementNamed(
        context,
        Routes.merchantStepBusiness,
        arguments: {'isAddingRole': widget.isAddingRole},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_getPageTitle()), centerTitle: true),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _getFormDescription(),
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ..._buildFormFields(),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: const Text('CONTINUAR'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  String _getPageTitle() {
    switch (widget.roleType) {
      case RoleType.driver:
        return widget.isAddingRole
            ? 'Agregar rol de Conductor'
            : 'Datos del Conductor';
      case RoleType.merchant:
        return widget.isAddingRole
            ? 'Agregar rol de Comercio'
            : 'Datos del Comercio';
      case RoleType.customer:
        return widget.isAddingRole
            ? 'Agregar rol de Cliente'
            : 'Datos del Cliente';
    }
  }

  String _getFormDescription() {
    if (widget.roleType == RoleType.merchant ||
        widget.roleType == RoleType.driver) {
      return 'Serás redirigido al formulario correspondiente...';
    }

    if (widget.isAddingRole) {
      return 'Completa la información adicional requerida para este rol.';
    } else {
      return 'Ingresa los datos solicitados para continuar con tu registro.';
    }
  }

  List<Widget> _buildFormFields() {
    // For merchant and driver roles, we're redirecting automatically
    // so we just show a loading indicator
    if (widget.roleType == RoleType.merchant ||
        widget.roleType == RoleType.driver) {
      return [
        const SizedBox(height: 20),
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 20),
        const Text(
          'Redirigiendo al formulario especializado...',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
      ];
    }

    // For customer role or other roles, show basic fields
    return [
      TextFormField(
        decoration: const InputDecoration(labelText: 'Nombre'),
        validator:
            (value) => (value?.isEmpty ?? true) ? 'Campo requerido' : null,
        onSaved: (value) => _formData['name'] = value,
      ),
      const SizedBox(height: 10),
      TextFormField(
        decoration: const InputDecoration(labelText: 'Teléfono'),
        keyboardType: TextInputType.phone,
        validator:
            (value) => (value?.isEmpty ?? true) ? 'Campo requerido' : null,
        onSaved: (value) => _formData['phone'] = value,
      ),
    ];
  }

  Future<void> _submitForm() async {
    // For merchant and driver, we've already redirected in initState
    // This is a fallback in case the user manually taps the button
    if (widget.roleType == RoleType.driver) {
      _redirectToRoleForm();
      return;
    }

    if (widget.roleType == RoleType.merchant) {
      _redirectToRoleForm();
      return;
    }

    // For customer role, process the minimal form
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);

      try {
        final authController = Provider.of<AuthController>(
          context,
          listen: false,
        );

        bool success;
        if (widget.isAddingRole) {
          // Adding a role to an existing user
          success = await authController.addRoleToCurrentUser(
            widget.roleType,
            _formData,
          );
        } else {
          // Este caso debería manejarse por la lógica de registro específica
          success = false;
        }        if (success && mounted) {
          // Mostrar feedback de confirmación al usuario
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Rol de cliente agregado correctamente!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to appropriate screen based on role
          Navigator.of(context).pushReplacementNamed(Routes.home_food);
        } else if (!success && mounted) {
          // Mostrar mensaje de error si la operación falló
          final authController = Provider.of<AuthController>(context, listen: false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authController.errorMessage ?? 'Error al agregar el rol de cliente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
