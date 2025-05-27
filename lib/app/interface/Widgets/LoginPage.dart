import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/SelectTypeAccount.dart';
import 'package:provider/provider.dart';
// Import admin redirector helper
import 'package:nicoya_now/app/features/auth/presentation/helpers/login_page_helper.dart';
import 'package:nicoya_now/app/features/admin/presentation/helpers/admin_redirector.dart';

class LoginPage extends StatefulWidget {
  final AccountType? accountType;
  const LoginPage({super.key, this.accountType});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late TapGestureRecognizer _tapRegister;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();    
    print('💼 Ruta Admin definida: ${Routes.home_admin}');
    _tapRegister =
        TapGestureRecognizer()
          ..onTap = () async {
            // Dirigir al usuario a la selección de tipo de cuenta
            Navigator.pushNamed(context, Routes.selecctTypeAccount);
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
                        'lib/app/interface/Public/LoginImage.png',
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
                  ),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Color(0xffd72a23),
                      ),
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
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
  
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa email y contraseña')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔐 Inicio de proceso de login');
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      
      print('📧 Intentando login con email: ${_emailController.text.trim()}');
      
      // Usar el método de la rama main para login con selección de rol
      final success = await authController.handleLoginWithRoleSelection(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (!mounted) return;
      
      if (success) {
        print('✅ Login exitoso');
        
        // Verificar si el usuario tiene rol de administrador
        if (authController.userRoles.contains('admin')) {
          print('👑 Usuario tiene rol de administrador');
          print('⚡ Redirigiendo a pantalla de admin: ${Routes.home_admin}');
          Navigator.pushNamedAndRemoveUntil(
            context, 
            Routes.home_admin, 
            (route) => false
          );
          return;
        }
        
        // Continuar con el flujo normal de la rama main
        if (authController.availableRoles.length > 1) {
          // Navegar a la página de selección de rol
          Navigator.pushReplacementNamed(context, Routes.selectUserRole);
        } else {
          // Solo hay un rol, navegar directamente según el rol
          final userRole = authController.userRole ?? 'customer';
          
          switch (userRole) {
            case 'customer':
              Navigator.pushNamedAndRemoveUntil(
                context, 
                Routes.clientNav,
                (route) => false
              );
              break;
            case 'driver':
              Navigator.pushNamedAndRemoveUntil(
                context, 
                Routes.home_food, // Cambiar a la pantalla para repartidores cuando esté disponible
                (route) => false
              );
              break;
            case 'merchant':
              Navigator.pushNamedAndRemoveUntil(
                context, 
                Routes.home_merchant,
                (route) => false
              );
              break;
            default:
              // Si no hay rol definido, ir a la pantalla principal
              Navigator.pushNamedAndRemoveUntil(
                context, 
                Routes.clientNav,
                (route) => false
              );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authController.errorMessage ?? 'Error desconocido'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}