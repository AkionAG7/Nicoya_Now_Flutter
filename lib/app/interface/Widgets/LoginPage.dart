import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/SelectTypeAccount.dart';

class LoginPage extends StatefulWidget {
  final AccountType? accountType;
  const LoginPage({Key? key, required this.accountType}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _passwordController = TextEditingController();
  late TapGestureRecognizer _tapRegister;

  @override
  void initState() {
    super.initState();
    _tapRegister =
        TapGestureRecognizer()
          ..onTap = () {
            switch (widget.accountType) {
              case AccountType.repartidor:
                Navigator.pushNamed(context, Routes.deliver_Form1);
                break;
              case AccountType.comercio:
                Navigator.pushNamed(context, Routes.comerse_Form);
                break;
              case AccountType.cliente:
                Navigator.pushNamed(context, Routes.client_Form);
                break;
              case null:
                // Opcional: manejar si accountType no fue pasado
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tipo de cuenta no definido')),
                );
                break;
            }
          };
  }

  @override
  void dispose() {
    _tapRegister.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
                        _obscureText ? Icons.visibility_off : Icons.visibility,
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
                ),

                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        () => print('exmaple'), // implementar logica de login
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
    );
  }
}
