import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordWithCodePage extends StatefulWidget {
  final String email; // lo recibes como argumento
  const ResetPasswordWithCodePage({super.key, required this.email});

  @override
  State<ResetPasswordWithCodePage> createState() =>
      _ResetPasswordWithCodePageState();
}

class _ResetPasswordWithCodePageState extends State<ResetPasswordWithCodePage> {
  final _codeController = TextEditingController();
  final _pwd1Controller = TextEditingController();
  final _pwd2Controller = TextEditingController();
  bool _saving = false;
  bool _obscurePassword1 = true;
  bool _obscurePassword2 = true;

  @override
  void dispose() {
    _codeController.dispose();
    _pwd1Controller.dispose();
    _pwd2Controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_pwd1Controller.text != _pwd2Controller.text) {
      _show('Las contraseñas no coinciden');
      return;
    }
    
    if (_pwd1Controller.text.length < 6) {
      _show('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    setState(() => _saving = true);

    try {
      final supa = Supabase.instance.client;
      final code = _codeController.text.trim();      // 1. obtener registro del código
      final res = await supa
          .from('password_reset_code')
          .select('user_id, expires_at')
          .eq('code', code)
          .eq('email', widget.email) // Verificar también el email
          .maybeSingle();

      if (res == null) {
        _show('Código inválido');
        return;
      }      final expires = DateTime.parse(res['expires_at']);
      if (expires.isBefore(DateTime.now())) {
        _show('Código expirado');
        return;
      }

      // 2. cambiar password
      final userId = res['user_id'] as String;
      final upd = await supa.auth.admin.updateUserById(
        userId,
        attributes: AdminUserAttributes(password: _pwd1Controller.text),
      );
      
      if (upd.user == null) {
        _show('Error al actualizar contraseña');
        return;
      }

      // 3. eliminar el código usado
      await supa.from('password_reset_code').delete().eq('user_id', userId);

      if (mounted) {
        Navigator.popUntil(context, (r) => r.isFirst); // vuelve a login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contraseña actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _show('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _show(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xfff10027)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Restablecer contraseña',
          style: TextStyle(
            color: Color(0xfff10027),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Ingresa el código',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xfff10027),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Hemos enviado un código de 6 dígitos a ${widget.email}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código de 6 dígitos',
                    hintText: '123456',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.security),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pwd1Controller,
                  decoration: InputDecoration(
                    labelText: 'Nueva contraseña',
                    hintText: 'Mínimo 6 caracteres',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword1 = !_obscurePassword1;
                        });
                      },
                      icon: Icon(
                        _obscurePassword1
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword1,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _pwd2Controller,
                  decoration: InputDecoration(
                    labelText: 'Repetir contraseña',
                    hintText: 'Confirma tu nueva contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword2 = !_obscurePassword2;
                        });
                      },
                      icon: Icon(
                        _obscurePassword2
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                  obscureText: _obscurePassword2,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd72a23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Cambiar contraseña',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Volver a enviar código',
                      style: TextStyle(
                        color: Color(0xffd72a23),
                        fontSize: 14,
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
