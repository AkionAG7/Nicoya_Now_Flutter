// lib/app/features/merchant/presentation/pages/home_merchant_page.dart

import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_products_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMerchantPage extends StatefulWidget {
  const HomeMerchantPage({super.key});

  @override
  State<HomeMerchantPage> createState() => _HomeMerchantPageState();
}

class _HomeMerchantPageState extends State<HomeMerchantPage> {
  int _selectedIndex = 0;

  // Obtenemos el merchantId del usuario logueado
  String get _merchantId => Supabase.instance.client.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    // Definimos la lista de pantallas según la pestaña seleccionada
    final pages = <Widget>[
      // 0: Pedidos del comercio
      const Center(child: Text('Pedidos del comercio')),
      // 1: Inventario de productos
      MerchantProductsPage(merchantId: _merchantId),
      // 2: Ajustes de comerciante (demo)
      const MerchantSettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
        // IndexedStack mantiene el estado de cada pantalla
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE60023),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.nicoyanow),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.maletatrabajo),
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.usuario),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class MerchantProductsPagePlaceholder extends StatelessWidget {
  const MerchantProductsPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyMerchantId = Supabase.instance.client.auth.currentUser!.id;
    return MerchantProductsPage(
      merchantId: dummyMerchantId,
    );
  }
}