import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/order_detail_page.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:nicoya_now/app/features/order/data/repositories/order_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_products_page.dart';
import 'package:nicoya_now/app/features/merchant/presentation/pages/merchant_settings_page.dart';
import 'package:nicoya_now/app/features/order/presentation/controllers/OrderController.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
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

  late final OrderController _orderController;

  String get _merchantId => Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _orderController = OrderController(
      repository: OrderRepositoryImpl(
        datasource: OrderDatasourceImpl(
          supabaseClient: Supabase.instance.client,
        ),
      ),
    );
    _orderController.addListener(() => setState(() {}));
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
      if (_isVerified) {
        _orderController.loadOrders(_merchantId);
      } else if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.merchantPending);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isVerified = false;
      });
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.merchantPending);
      }
    }
  }

  Widget _buildOrdersTab() {
    if (_orderController.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_orderController.error != null) {
      return Center(child: Text('Error: ${_orderController.error}'));
    }
    final orders = _orderController.orders;
    if (orders.isEmpty) {
      return const Center(child: Text('No hay pedidos'));
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (ctx, i) {
        final o = orders[i];
        return ListTile(
          leading: const Icon(Icons.shopping_bag),
          title: Text('Pedido'),
          subtitle: Text('Total: \$${o.total.toStringAsFixed(2)}'),
          trailing: Text(
            o.status.toString().split('.').last.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailPage(orderId: o.order_id),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (!_isVerified) {
      return const Scaffold(
        body: Center(
          child: Text('Tu cuenta de comerciante está pendiente de verificación'),
        ),
      );
    }

    final pages = <Widget>[
      _buildOrdersTab(),
      MerchantProductsPage(merchantId: _merchantId),
      const MerchantSettingsPage(),
    ];

    return Scaffold(
      body: SafeArea(
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
            label: 'Pedidos',
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