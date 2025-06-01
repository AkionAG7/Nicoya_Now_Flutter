import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/interface/Widgets/UserBottomBarCustomer.dart';
import 'package:nicoya_now/app/features/order/presentation/pages/Carrito.dart';
import 'package:nicoya_now/app/features/products/presentation/pages/home_food.dart';

class BottomNavigator extends StatefulWidget {
  const BottomNavigator({Key? key}) : super(key: key);

  @override
  _BottomNavigatorState createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  int _currentIndex = 0;
  Key _carritoKey = UniqueKey();

  final List<Widget> _pages = [
    HomeFood(),
    const Placeholder(),
    Carrito(),
    UserBottomBarCustomer(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFf10027),

        currentIndex: _currentIndex,
        onTap: (i) {
          if (i == 2) {
            // Forzar que Carrito
            setState(() {
              _carritoKey = UniqueKey();
              _currentIndex = i;
            });
          } else {
            setState(() => _currentIndex = i);
          }
        },

        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.grey[400],
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.white),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.carritocompras, color: Colors.white),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.usuario, color: Colors.white),
            label: 'Usuario',
          ),
        ],
      ),
    );
  }
}
