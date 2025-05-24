import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({Key? key}) : super(key: key);

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName1 = TextEditingController();
  final _lastName2 = TextEditingController();
  final _phone     = TextEditingController();
  final _address   = TextEditingController();
  final _email     = TextEditingController();
  final _password  = TextEditingController();
  final _passConf  = TextEditingController();

  bool   _loading  = false;
  bool   _hidePw   = true;
  bool   _hidePw2  = true;
  String? _error;

 
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _passConf.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _loading = true;
      _error   = null;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      
      final success = await authController.signUp(
        email: _email.text.trim(),
        password: _password.text,
        firstName: _firstName.text.trim(),
        lastName1: _lastName1.text.trim(),
        lastName2: _lastName2.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
      );

      if (!mounted) return;
      
      if (success) {
        Navigator.pop(context); 
      } else {
        setState(() => _error = authController.errorMessage);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName1,
      _lastName2,
      _phone,
      _address,
      _email,
      _password,
      _passConf,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _text(String label, TextEditingController c,
      {TextInputType? type, int? maxLen}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      maxLength: maxLen,
      buildCounter: (_, {required currentLength, maxLength, required isFocused}) => null,
      decoration: InputDecoration(labelText: label),
      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Crea tu cuenta',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                _text('Nombre', _firstName, type: TextInputType.name),
                const SizedBox(height: 20),
                _text('Primer apellido', _lastName1, type: TextInputType.name),
                const SizedBox(height: 20),
                _text('Segundo apellido', _lastName2, type: TextInputType.name),
                const SizedBox(height: 20),
                _text('Teléfono', _phone,
                    type: TextInputType.phone, maxLen: 8),
                const SizedBox(height: 20),
                _text('Domicilio', _address,
                    type: TextInputType.streetAddress),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) =>
                      v != null && v.contains('@') ? null : 'Correo inválido',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _password,
                  obscureText: _hidePw,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _hidePw ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _hidePw = !_hidePw),
                    ),
                  ),
                  validator: (v) =>
                      v != null && v.length >= 6 ? null : 'Mínimo 6 caracteres',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passConf,
                  obscureText: _hidePw2,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(_hidePw2
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() => _hidePw2 = !_hidePw2),
                    ),
                  ),
                  validator: (v) =>
                      v == _password.text ? null : 'No coincide',
                ),
                const SizedBox(height: 30),
                if (_error != null)
                  Text(_error!,
                      style: const TextStyle(color: Colors.red, fontSize: 14)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd72a23),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text('Registrar',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                // Google sign-up button
                Consumer<AuthController>(
                  builder: (context, authController, _) => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Aquí implementarías la lógica para sign-in con Google
                        // usando el controlador de autenticación
                      },
                      icon: const Icon(Icons.login, size: 24),
                      label: const Text('Google', style: TextStyle(fontSize: 18)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffd72a23),
                        side: const BorderSide(color: Color(0xffd72a23)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
  }
}
