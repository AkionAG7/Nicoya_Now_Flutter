import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';

class RoleFormPage extends StatefulWidget {
  final RoleType roleType;
  final bool isAddingRole; // true if adding role to existing user, false for new registration

  const RoleFormPage({
    Key? key,
    required this.roleType,
    this.isAddingRole = false,
  }) : super(key: key);

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle()),
        centerTitle: true,
      ),
      body: _isLoading
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
                        child: const Text('CONTINUAR'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
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
        return widget.isAddingRole ? 'Registrarse como Conductor' : 'Datos del Conductor';
      case RoleType.merchant:
        return widget.isAddingRole ? 'Registrarse como Comercio' : 'Datos del Comercio';
      case RoleType.customer:
        return widget.isAddingRole ? 'Registrarse como Cliente' : 'Datos del Cliente';
    }
  }

  String _getFormDescription() {
    if (widget.isAddingRole) {
      return 'Completa la información adicional requerida para registrarte con este rol.';
    } else {
      return 'Ingresa los datos solicitados para continuar con tu registro.';
    }
  }
  List<Widget> _buildFormFields() {
    switch (widget.roleType) {
      case RoleType.driver:
        return _buildDriverFields();
      case RoleType.merchant:
        return _buildMerchantFields();
      case RoleType.customer:
        return _buildCustomerFields();
    }
  }

  List<Widget> _buildDriverFields() {
    return [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Número de Identificación',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
        onSaved: (value) => _formData['id_number'] = value,
      ),
      const SizedBox(height: 15),
      const Text(
        'Importante: Tu cuenta como conductor será verificada antes de poder acceder. Te notificaremos cuando esto suceda.',
        style: TextStyle(color: Colors.red),
      ),
    ];
  }

  List<Widget> _buildMerchantFields() {
    return [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Número de Identificación Tributaria',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
        onSaved: (value) => _formData['id_number'] = value,
      ),
      const SizedBox(height: 15),
      // Add more merchant fields as needed
    ];
  }

  List<Widget> _buildCustomerFields() {
    return [
      TextFormField(
        decoration: const InputDecoration(
          labelText: 'Dirección',
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
        onSaved: (value) => _formData['address'] = value,
      ),
      const SizedBox(height: 15),
      // Add more customer fields as needed
    ];
  }
  Future<void> _submitForm() async {
    // Special handling for driver role - navigate to DeliverForm1
    if (widget.roleType == RoleType.driver && widget.isAddingRole) {
      Navigator.pushNamed(
        context,
        Routes.deliver_Form1,
        arguments: {
          'isAddingRole': true,
        },
      );
      return;
    }
    
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      setState(() => _isLoading = true);

      try {
        final authController = Provider.of<AuthController>(context, listen: false);
        
        bool success;
        if (widget.isAddingRole) {
          // Adding a role to an existing user
          success = await authController.addRoleToCurrentUser(widget.roleType, _formData);
        } else {
          // This would be handled by the specific signup methods in the original flow
          success = false;
        }

        if (success && mounted) {
          // Navigate to appropriate screen based on role
          String nextRoute = '/home';
          switch (widget.roleType) {
            case RoleType.merchant:
              nextRoute = '/merchant/home';
              break;
            case RoleType.customer:
              nextRoute = '/customer/home';
              break;
            case RoleType.driver:
              nextRoute = '/driver/home';
              break;
          }
          
          Navigator.of(context).pushReplacementNamed(nextRoute);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }
}
