import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/service_locator.dart';
import '../controllers/admin_merchant_controller.dart';
import '../controllers/admin_driver_controller.dart';
import 'admin_dashboard_page.dart';
import 'merchants_management_page.dart';
import 'drivers_management_page.dart';
import '../../../../interface/Widgets/notification_bell.dart';
import '../../../../interface/Navigators/routes.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar controladores si es necesario
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    // Mostrar diálogo de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFE60023),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Cerrar sesión en Supabase
        await Supabase.instance.client.auth.signOut();
        
        if (mounted) {
          // Navegar a la pantalla de navegación inicial
          Navigator.pushNamedAndRemoveUntil(
            context,
            Routes.appStartNavigation,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => locator<AdminMerchantController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => locator<AdminDriverController>(),
        ),
      ],
      child: Scaffold(    
        appBar: AppBar(
          title: const Text('Panel de Administración'),
          backgroundColor: const Color(0xFFE60023),
          foregroundColor: Colors.white,
          actions: [
            const NotificationBell(),
            const SizedBox(width: 8),
            // Menú desplegable para opciones de administrador
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout();
                }
              },
              icon: const Icon(
                Icons.account_circle,
                size: 28,
                color: Colors.white,
              ),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Color(0xFFE60023),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: const [
              AdminDashboardPage(),
              MerchantsManagementPage(),
              DriversManagementPage(),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFFE60023),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Comercios',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              label: 'Repartidores',
            ),
          ],
        ),
      ),
    );
  }
}
