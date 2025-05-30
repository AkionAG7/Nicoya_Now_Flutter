import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/service_locator.dart';
import '../controllers/admin_merchant_controller.dart';
import '../controllers/admin_driver_controller.dart';
import 'admin_dashboard_page.dart';
import 'merchants_management_page.dart';
import 'drivers_management_page.dart';

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
