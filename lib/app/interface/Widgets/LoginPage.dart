import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:provider/provider.dart';

enum AccountType { repartidor, comercio, cliente }

class LoginPage extends StatefulWidget {
  final AccountType? accountType;
  const LoginPage({Key? key, this.accountType}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText   = true;
  bool _rememberMe    = false;
  bool _isLoading     = false;

  final _email    = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* recognizer se crea aquí: siempre válido */
    final tapRegister = TapGestureRecognizer()
      ..onTap = () => Navigator.pushNamed(context, Routes.selecctTypeAccount);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('lib/app/interface/public/LoginImage.png',
                            height: 270, width: double.infinity, fit: BoxFit.cover),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Iniciar sesión',
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold,
                        color: Color(0xfff10027))),
                ),
                const SizedBox(height: 10),
                _textField(_email, 'Email', hint: 'you@gmail.com',
                           inputType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _passwordField(),
                Row(
                  children: [
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('Recuérdame', style: TextStyle(fontSize: 12)),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _rememberMe,
                        onChanged: (v) => setState(() => _rememberMe = !_rememberMe),
                      ),
                    ),
                    const Text('¿Olvidaste tu contraseña?', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 60, width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd72a23),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Iniciar sesión',
                            style: TextStyle(color: Colors.white,
                                             fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: '¿No tienes una cuenta?',
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                    children: [
                      TextSpan(
                        text: ' Regístrate',
                        recognizer: tapRegister,
                        style: const TextStyle(
                          color: Color(0xffd72a23),
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('O inicia sesión con',
                           style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(NicoyaNowIcons.facebook, size: 40),
                               onPressed: () {}),
                    const SizedBox(width: 40),
                    IconButton(icon: const Icon(NicoyaNowIcons.google, size: 40),
                               onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- inputs helpers ----------
  Widget _textField(TextEditingController c, String label,
      {String? hint, TextInputType inputType = TextInputType.text}) =>
    TextFormField(
      controller: c,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
    );

  Widget _passwordField() => TextFormField(
        controller: _password,
        obscureText: _obscureText,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: '*******',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: IconButton(
            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscureText = !_obscureText),
          ),
        ),
      );

  // ---------- login ----------
  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese email y contraseña')));
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthController>();

    final ok = await auth.signIn(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Error desconocido')));
      return;
    }

    await auth.loadUserRoles();
    final roles = auth.userRoles ?? [];

    // si se abrió desde selectTypeAccount → devolver true
    final sel = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>?;
    final selectedRole = sel?['selectedRole'] as String?;
    if (selectedRole != null) {
      Navigator.of(context).pop(true);
      return;
    }

    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('No tienes roles asignados'),
                 action: SnackBarAction(
                   label: 'Registrar',
                   onPressed: () => Navigator.pushNamed(context, Routes.selecctTypeAccount))));
    } else if (roles.length == 1) {
      _navigateToRoleScreen(roles.first['role']['slug'] as String);
    } else {
      _showRoleDialog(auth);
    }
  }

  void _showRoleDialog(AuthController auth) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Selecciona tu rol'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: (auth.userRoles ?? []).map((r) {
            final slug  = r['role']['slug']  as String;
            final label = r['role']['label'] as String;
            return ListTile(
              leading: const Icon(Icons.person, color: Color(0xffd72a23)),
              title: Text(label),
              onTap: () {
                Navigator.pop(context);
                _navigateToRoleScreen(slug);
              });
          }).toList(),
        ),
      ));
  }

  void _navigateToRoleScreen(String slug) {
    String route = Routes.home_food;                 // cliente por defecto
    if (slug == 'merchant') route = Routes.home_food;  // placeholder
    if (slug == 'driver')   route = Routes.home_food;  // placeholder

    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }
}
