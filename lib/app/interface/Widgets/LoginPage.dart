import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/Widgets/SelectTypeAccount.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  final AccountType? accountType;
  const LoginPage({Key? key, this.accountType}) : super(key: key);

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
    super.initState();    _tapRegister =
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
  // Método para navegar según el rol
  void _navigateToRoleScreen(BuildContext context, String role) {
    // Por ahora todas las rutas van a home_food, pero aquí podrías
    // agregar rutas específicas para cada rol
    String route = Routes.home_food;
    switch (role) {
      case 'driver':
        route = Routes.home_food; // Cambiar cuando exista una pantalla específica
        break;
      case 'merchant':
        route = Routes.home_food; // Cambiar cuando exista una pantalla específica
        break;
      case 'client':
      default:
        route = Routes.home_food;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );
  }

  // Método para construir el diálogo de selección de rol
  Widget _buildRoleSelectionDialog(BuildContext context, AuthController authController) {
    return AlertDialog(
      title: Text('Selecciona tu rol'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: (authController.userRoles ?? []).map<Widget>((roleData) {
          final role = roleData['role'] as Map<String, dynamic>;
          final slug = role['slug'] as String;
          final label = role['label'] as String;

          IconData icon;
          switch (slug) {
            case 'driver':
              icon = Icons.delivery_dining;
              break;
            case 'merchant':
              icon = Icons.store;
              break;
            case 'client':
            default:
              icon = Icons.person;
          }

          return ListTile(
            leading: Icon(icon, color: Color(0xffd72a23)),
            title: Text(label),
            onTap: () {
              Navigator.pop(context); // Cerrar diálogo
              _navigateToRoleScreen(context, slug);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa email y contraseña')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final success = await authController.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        await authController.loadUserRoles();
        
        // Obtener el rol seleccionado de los argumentos si existe
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final selectedRole = args?['selectedRole'] as String?;
        
        if (selectedRole != null) {
          // Si venimos de la selección de tipo de cuenta, retornar true
          Navigator.of(context).pop(true);
        } else {
          final roles = authController.userRoles ?? [];
          if (roles.isEmpty) {
            // Si no tiene roles, mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No tienes roles asignados. Por favor, registra un rol.'),
                action: SnackBarAction(
                  label: 'Registrar',
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.selecctTypeAccount);
                  },
                ),
              ),
            );
          } else if (roles.length > 1) {
            // Si tiene múltiples roles, mostrar diálogo de selección
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildRoleSelectionDialog(context, authController),
            );
          } else {
            // Si solo tiene un rol, navegar a la pantalla correspondiente
            final role = roles.first['role']['slug'] as String;
            _navigateToRoleScreen(context, role);
          }
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authController.errorMessage ?? 'Error desconocido')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión. Por favor, verifica tu conexión a internet.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
