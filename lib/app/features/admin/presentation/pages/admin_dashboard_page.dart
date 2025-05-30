import 'package:flutter/material.dart';
import '../widgets/stat_card.dart';
import '../widgets/activity_item.dart';

/// Panel principal del administrador
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bienvenido, Administrador',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          // Estadísticas en tarjetas
          Row(
            children: [
              StatCard(
                title: 'Comercios',
                value: '12',
                icon: Icons.store,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              StatCard(
                title: 'Repartidores',
                value: '8',
                icon: Icons.delivery_dining,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              StatCard(
                title: 'Usuarios',
                value: '124',
                icon: Icons.people,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              StatCard(
                title: 'Pedidos',
                value: '43',
                icon: Icons.shopping_bag,
                color: Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          const Text(
            'Actividad reciente',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Lista de actividades recientes
          Expanded(
            child: ListView(
              children: const [
                ActivityItem(
                  title: 'Nuevo comercio registrado',
                  description: 'Restaurante Nicoya',
                  time: '10 minutos',
                  icon: Icons.store,
                ),
                ActivityItem(
                  title: 'Conductor aprobado',
                  description: 'Carlos Rodríguez',
                  time: '30 minutos',
                  icon: Icons.delivery_dining,
                ),
                ActivityItem(
                  title: 'Nuevo pedido',
                  description: 'Pedido #1234',
                  time: '1 hora',
                  icon: Icons.shopping_bag,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
