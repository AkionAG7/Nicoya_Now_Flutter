import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeliverForm1 extends StatefulWidget {
  const DeliverForm1({Key? key}) : super(key: key);
  @override State<DeliverForm1> createState() => _DeliverForm1State();
}

class _DeliverForm1State extends State<DeliverForm1> {
  // ───── controladores ─────
  final _cedula     = TextEditingController();   // cédula (ID nacional)
  final _license    = TextEditingController();   // Nº de licencia de conducir
  final _nombre     = TextEditingController();
  final _apellido1  = TextEditingController();
  final _apellido2  = TextEditingController();
  final _telefono   = TextEditingController();
  final _email      = TextEditingController();
  final _pass       = TextEditingController();
  final _passConf   = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final supa     = GetIt.I<SupabaseClient>();

  bool   _hidePw = true, _hidePw2 = true, _loading = false;
  String? _error;

  // ───── lógica Supabase + navegación ─────
  Future<void> _next() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pass.text != _passConf.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      // 1· crear usuario
      final res = await supa.auth.signUp(
        email   : _email.text.trim(),
        password: _pass.text,
      );
      if (res.user == null) throw const AuthException('No se pudo crear la cuenta');
      final uid = res.user!.id;

      // 2· actualizar profile (incluye cédula)
      await supa.from('profile').update({
        'first_name' : _nombre.text.trim(),
        'last_name1' : _apellido1.text.trim(),
        'last_name2' : _apellido2.text.trim(),
        'phone'      : _telefono.text.trim(),
        'role'       : 'driver',
        'id_number'  : _cedula.text.trim(),     
      }).eq('user_id', uid);

      // 3· ir a la pantalla de documentos con la licencia
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        Routes.deliver_Form2,
        arguments: {
          'uid'          : uid,
          'licenseNumber': _license.text.trim(),
        },
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
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
          title: const Text('Crea tu cuenta de repartidor',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(children: [
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
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Continuar',
                            style: TextStyle(fontSize: 20)),
                  ),
                ),
              ]),
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
      _passConf
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
