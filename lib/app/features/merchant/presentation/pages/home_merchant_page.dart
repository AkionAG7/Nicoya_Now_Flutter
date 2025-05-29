// lib/app/features/merchant/presentation/pages/home_merchant_page.dart

import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_products_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_settings_page.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMerchantPage extends StatefulWidget {
  const HomeMerchantPage({Key? key}) : super(key: key);

  @override
  State<HomeMerchantPage> createState() => _HomeMerchantPageState();
}

class _HomeMerchantPageState extends State<HomeMerchantPage> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isVerified = false;

  // Obtenemos el merchantId del usuario logueado
  String get _merchantId => Supabase.instance.client.auth.currentUser!.id;
  
  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }
  
  Future<void> _checkVerificationStatus() async {
    try {
      final result = await Supabase.instance.client
          .from('merchant')
          .select('is_active')
          .eq('merchant_id', _merchantId)
          .single();
          
      setState(() {
        _isVerified = result['is_active'] ?? false;
        _isLoading = false;
      });
      
      // Si no está verificado, redirigir a la página de pendiente
      if (!_isVerified && mounted) {
        Navigator.pushReplacementNamed(context, Routes.merchantPending);
      }
    } catch (e) {
      print('Error verificando estado de merchant: $e');
      setState(() {
        _isLoading = false;
        _isVerified = false;
      });
      
      // En caso de error, también redirigir
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.merchantPending);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Si no está verificado, mostrar mensaje mientras se redirige
    if (!_isVerified) {
      return const Scaffold(
        body: Center(
          child: Text('Tu cuenta de comerciante está pendiente de verificación'),
        ),
      );
    }

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
