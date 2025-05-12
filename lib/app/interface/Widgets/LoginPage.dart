import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/SelectTypeAccount.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, AccountType? accountType}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TapGestureRecognizer _tapRegister;
  @override
  void initState() {
    super.initState();
    _tapRegister =
        TapGestureRecognizer()
          ..onTap = () async {
            final email = await Navigator.pushNamed(context, Routes.register_user_page);
            if (email != null && email is String) {
              setState(() {
                _emailController.text = email;
              });
            }
          };
  }
  @override
  void dispose() {
    _tapRegister.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 270,
                      child: Image.asset(
                        'lib/app/interface/public/LoginImage.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xfff10027),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    key: const Key('emailField'),
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'You@gmail.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextFormField(
                    key: const Key('passwordField'),
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'YouPassword',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          key: const Key('rememberMeCheckbox'),
                          title: const Text(
                            'Recuerdame',
                            style: TextStyle(fontSize: 12),
                          ),
                          value: _rememberMe,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = !_rememberMe;
                            });
                          },
                        ),
                      ),

                      Text(
                        '¿Haz olvidado tu contraseña?',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {                        try {
                          final supabase = GetIt.instance<SupabaseClient>();
                          final email = _emailController.text;
                          final pass = _passwordController.text;

                          final res = await supabase.auth.signInWithPassword(
                            email: email,
                            password: pass,
                          );                          if (res.session != null) {
                            if (!mounted) return;
                            Navigator.pushReplacementNamed(context, Routes.preLogin); // Esta ruta lleva al Home
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color(0xffd72a23),
                      ),
                      child: Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  RichText(
                    text: TextSpan(
                      text: '¿No tienes una cuenta?',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      children: [
                        TextSpan(
                          text: ' Registrate',
                          style: TextStyle(
                            color: Color(0xffd72a23),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          recognizer: _tapRegister,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    'O inicia sesión con',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed:
                            () => print('hello'), // implementar logica de login
                        icon: Icon(NicoyaNowIcons.facebook, size: 40),
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        onPressed:
                            () => print('hello'), // implementar logica de login
                        icon: Icon(NicoyaNowIcons.google, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
