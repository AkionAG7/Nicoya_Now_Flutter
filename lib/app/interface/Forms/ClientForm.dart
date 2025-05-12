import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientForm extends StatefulWidget {
  const ClientForm({Key? key}) : super(key: key);

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();

  // ───── Controllers ──────────────────────────────────────────────
  final _firstName = TextEditingController();
  final _lastName1 = TextEditingController();
  final _lastName2 = TextEditingController();
  final _phone     = TextEditingController();
  final _address   = TextEditingController();
  final _email     = TextEditingController();
  final _password  = TextEditingController();
  final _passConf  = TextEditingController();

  final _supabase  = GetIt.I<SupabaseClient>();

  bool   _loading  = false;
  bool   _hidePw   = true;
  bool   _hidePw2  = true;
  String? _error;

  // ───── Registro ────────────────────────────────────────────────
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
      // 1. Crea usuario
      final res = await _supabase.auth.signUp(
        email   : _email.text.trim(),
        password: _password.text,
      );
      if (res.user == null) throw const AuthException('No se pudo crear la cuenta');

      final uid = res.user!.id;

      // 2. Actualiza perfil (trigger ya creó fila)
      await _supabase.from('profile').update({
        'first_name' : _firstName.text.trim(),
        'last_name1' : _lastName1.text.trim(),
        'last_name2' : _lastName2.text.trim(),
        'phone'      : _phone.text.trim(),
      }).eq('user_id', uid);

      // 3. Inserta dirección básica
      await _supabase.from('address').insert({
        'user_id' : uid,
        'street'  : _address.text.trim(),
        'district': '',
        'lat'     : null,
        'lng'     : null,
        'note'    : '',
      });

      if (!mounted) return;
      Navigator.pop(context); // o navega a Home
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
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

  // ───── UI helpers ───────────────────────────────────────────────
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
                // botón Google (placeholder)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () => print('login con Google'),
                    icon: const Icon(NicoyaNowIcons.google, size: 24),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
