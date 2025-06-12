import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliverForm1 extends StatefulWidget {
  const DeliverForm1({super.key});
  @override
  State<DeliverForm1> createState() => _DeliverForm1State();
}

class _DeliverForm1State extends State<DeliverForm1> {
  final _cedula = TextEditingController();
  final _license = TextEditingController();
  final _nombre = TextEditingController();
  final _apellido1 = TextEditingController();
  final _apellido2 = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _passConf = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final supa = GetIt.I<SupabaseClient>();
  bool _hidePw = true, _hidePw2 = true, _loading = false;
  String? _error;
  bool _isAddingRole =
      false; // Flag to indicate if user is adding role to existing account

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if arguments are passed from navigation
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _isAddingRole = args['isAddingRole'] as bool? ?? false;
    }
  }

  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;

    // For adding role, we don't need password validation
    if (!_isAddingRole) {
      if (_pass.text != _passConf.text) {
        setState(() => _error = 'Las contraseñas no coinciden');
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );      bool success;
      if (_isAddingRole) {
        // User is adding driver role to existing account
        success = await authController.addRoleToCurrentUser(RoleType.driver, {
          'id_number': _cedula.text.trim(),
          'license_number': _license.text.trim(),
        });

        if (success && mounted) {
          // Continue to DeliverForm2 for vehicle/document upload
          Navigator.pushReplacementNamed(
            context,
            Routes.deliver_Form2,
            arguments: {
              'uid': authController.user!.id,
              'licenseNumber': _license.text.trim(),
              'isAddingRole': true, // Pass this flag to DeliverForm2
            },
          );
        }} else {
        // New user registration
        final result = await authController.signUpDriver(
          email: _email.text.trim(),
          password: _pass.text,
          firstName: _nombre.text.trim(),
          lastName1: _apellido1.text.trim(),
          lastName2: _apellido2.text.trim(),
          phone: _telefono.text.trim(),
          idNumber: _cedula.text.trim(),
        );

        success = result['success'] ?? false;        if (success && mounted) {
          // For driver registration, always continue to DeliverForm2 to complete the process
          // The role has been added, now we need to collect vehicle and document info
          Navigator.pushReplacementNamed(
            context,
            Routes.deliver_Form2,
            arguments: {
              'uid': authController.user!.id,
              'licenseNumber': _license.text.trim(),
              'isAddingRole': false, // This is new user registration, not adding role
            },
          );
        } else {
          setState(() => _error = result['message'] ?? 'Error en el registro');
        }
      }

      if (!success) {
        setState(() => _error = authController.errorMessage);
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String l) => InputDecoration(labelText: l);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        _isAddingRole
            ? 'Agregar rol de repartidor'
            : 'Crea tu cuenta de repartidor',
        style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Show explanation text for role addition
              if (_isAddingRole) ...[
                const Text(
                  'Para agregar el rol de repartidor a tu cuenta, necesitamos algunos datos adicionales:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],

              // Cédula
              TextFormField(
                controller: _cedula,
                decoration: _dec('Cédula'),
                maxLength: 9,
                keyboardType: TextInputType.number,
                validator: (v) => v!.length == 9 ? null : '9 dígitos',
              ),
              const SizedBox(height: 20),

              // Nº de Licencia
              TextFormField(
                controller: _license,
                decoration: _dec('Número de licencia'),
                maxLength: 12,
                validator: (v) => v!.isNotEmpty ? null : 'Requerido',
              ),
              const SizedBox(height: 20),

              // Only show these fields for new user registration
              if (!_isAddingRole) ...[
                // Nombre
                TextFormField(
                  controller: _nombre,
                  decoration: _dec('Nombre'),
                  validator: (v) => v!.isNotEmpty ? null : 'Requerido',
                ),
                const SizedBox(height: 20),
                // Apellido 1
                TextFormField(
                  controller: _apellido1,
                  decoration: _dec('Apellido 1'),
                  validator: (v) => v!.isNotEmpty ? null : 'Requerido',
                ),
                const SizedBox(height: 20),
                // Apellido 2
                TextFormField(
                  controller: _apellido2,
                  decoration: _dec('Apellido 2'),
                  validator: (v) => v!.isNotEmpty ? null : 'Requerido',
                ),
                const SizedBox(height: 20),
                // Teléfono
                TextFormField(
                  controller: _telefono,
                  decoration: _dec('Teléfono'),
                  maxLength: 8,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length == 8 ? null : '8 dígitos',
                ),
                const SizedBox(height: 20),
                // Email
                TextFormField(
                  controller: _email,
                  decoration: _dec('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.contains('@') ? null : 'Correo inválido',
                ),
                const SizedBox(height: 20),
                // Password
                TextFormField(
                  controller: _pass,
                  decoration: _dec('Contraseña'),
                  obscureText: _hidePw,
                  validator: (v) => v!.length >= 6 ? null : 'Mín 6',
                ),
                const SizedBox(height: 20),
                // Confirmar
                TextFormField(
                  controller: _passConf,
                  decoration: _dec('Confirmar contraseña'),
                  obscureText: _hidePw2,
                  validator: (v) => v == _pass.text ? null : 'No coincide',
                ),
                const SizedBox(height: 20),
              ],

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff10027),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                            _isAddingRole ? 'Agregar rol' : 'Continuar',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  void dispose() {
    for (final c in [
      _cedula,
      _license,
      _nombre,
      _apellido1,
      _apellido2,
      _telefono,
      _email,
      _pass,
      _passConf,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
