import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_products_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMerchantPage extends StatefulWidget {
  const HomeMerchantPage({super.key});

  @override
  State<HomeMerchantPage> createState() => _HomeMerchantPageState();
}

class _HomeMerchantPageState extends State<HomeMerchantPage> {
  int _selectedIndex = 0;

  // Lista de widgets para cada pestaña
  static const List<Widget> _pages = <Widget>[
    // aquí podrías usar tu OrdersPage
    Center(child: Text('Pedidos del comercio')),
    // MerchantProductsPage espera merchantId; aquí uso placeholder:
    MerchantProductsPagePlaceholder(),
    Center(child: Text('Ajustes de comerciante')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ocultamos AppBar para que el diseño sea coherente con el mock
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
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
            icon: Icon(NicoyaNowIcons.basurero), // Home icon
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.maletatrabajo), // Productos icon
            label: 'Inventario',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.campana), // Ajustes icon
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
