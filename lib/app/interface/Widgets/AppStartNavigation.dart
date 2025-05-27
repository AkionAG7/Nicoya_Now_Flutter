import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppStartNavigation extends StatefulWidget {
  const AppStartNavigation({Key? key}) : super(key: key);

  @override
  _AppStartNavigationState createState() => _AppStartNavigationState();
}

class _AppStartNavigationState extends State<AppStartNavigation> {
  bool _isLoading = true;
  bool _isFirstTime = false;
  bool _isAuthenticated = false;
  bool _hasMultipleRoles = false;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    try {
      // 1. Verificar si es la primera vez que abre la app
      final prefs = await SharedPreferences.getInstance();
      final alreadyOpened = prefs.getBool('already_opened') ?? false;
      
      if (!alreadyOpened) {
        await prefs.setBool('already_opened', true);
        setState(() {
          _isFirstTime = true;
          _isLoading = false;
        });
        return;
      }
      
      // 2. Verificar si hay sesión activa
      final auth = Supabase.instance.client.auth;
      final session = auth.currentSession;
      
      if (session == null) {
        setState(() {
          _isLoading = false;
          _isAuthenticated = false;
        });
        return;
      }
      
      // 3. Verificar si el usuario tiene múltiples roles
      try {
        final userId = auth.currentUser!.id;
        final rolesResult = await Supabase.instance.client
            .from('user_role')
            .select('role:role_id(slug)')
            .eq('user_id', userId);
            
        final hasMultipleRoles = rolesResult.length > 1;
        
        setState(() {
          _isLoading = false;
          _isAuthenticated = true;
          _hasMultipleRoles = hasMultipleRoles;
        });
      } catch (e) {
        // Si hay error, asumir que no está autenticado correctamente
        setState(() {
          _isLoading = false;
          _isAuthenticated = false;
        });
      }
    } catch (e) {
      // Por defecto, ir a la pantalla de selección de cuenta
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFFD72A23),
              ),
              SizedBox(height: 20),
              Text('Cargando...'),
            ],
          ),
        ),
      );
    }

    // Usamos PostFrameCallback para asegurarnos de que el árbol de widgets esté construido
    // antes de navegar a otra ruta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isFirstTime) {
        // Si es la primera vez, mostrar las pantallas de onboarding
        Navigator.pushReplacementNamed(context, Routes.splashFT1);
      } else if (_isAuthenticated && _hasMultipleRoles) {
        // Si está autenticado y tiene múltiples roles, mostrar selector de roles
        Navigator.pushReplacementNamed(context, Routes.selectUserRole);
      } else if (_isAuthenticated) {
        // Si está autenticado pero solo tiene un rol, ir directo a la página principal
        Navigator.pushReplacementNamed(context, Routes.home_food);      } else {
        // Si no está autenticado, redirigir a la página Home en lugar de SelectTypeAccount
        Navigator.pushReplacementNamed(context, Routes.preLogin);
      }
    });

    // Mientras se procesa la navegación, mostrar una pantalla en blanco
    return const SizedBox.shrink();
  }
}
