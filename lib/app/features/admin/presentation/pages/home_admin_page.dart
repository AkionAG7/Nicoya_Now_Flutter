import 'package:flutter/material.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _AdminDashboardPage(),
            _MerchantsManagementPage(),
            _DriversManagementPage(),
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
            icon: Icon(Icons.dashboard), // Dashboard icon
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store), // Comercios icon
            label: 'Comercios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining), // Repartidores icon
            label: 'Repartidores',
          ),
        ],
      ),
    );
  }
}

// Panel principal del administrador
class _AdminDashboardPage extends StatelessWidget {
  const _AdminDashboardPage();

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
              _StatCard(
                title: 'Comercios',
                value: '12',
                icon: Icons.store,
                color: Colors.blue,
              ),
              const SizedBox(width: 16),
              _StatCard(
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
              _StatCard(
                title: 'Usuarios',
                value: '124',
                icon: Icons.people,
                color: Colors.orange,
              ),
              const SizedBox(width: 16),
              _StatCard(
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
                _ActivityItem(
                  title: 'Nuevo comercio registrado',
                  description: 'Restaurante Nicoya',
                  time: '10 minutos',
                  icon: Icons.store,
                ),
                _ActivityItem(
                  title: 'Conductor aprobado',
                  description: 'Carlos Rodríguez',
                  time: '30 minutos',
                  icon: Icons.delivery_dining,
                ),
                _ActivityItem(
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

// Página de gestión de comerciantes
class _MerchantsManagementPage extends StatelessWidget {
  const _MerchantsManagementPage();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Comerciantes',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Filtros o búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar comerciante...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Lista de comerciantes
          Expanded(
            child: ListView(
              children: [
                _MerchantListItem(
                  name: 'Restaurante Nicoya',
                  status: 'Pendiente',
                  onApprove: () => _showApprovalDialog(context, 'Restaurante Nicoya'),
                ),
                _MerchantListItem(
                  name: 'Café del Centro',
                  status: 'Aprobado',
                  onApprove: () {},
                  isApproved: true,
                ),
                _MerchantListItem(
                  name: 'Tienda de Abarrotes',
                  status: 'Pendiente',
                  onApprove: () => _showApprovalDialog(context, 'Tienda de Abarrotes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showApprovalDialog(BuildContext context, String merchantName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aprobar $merchantName'),
        content: const Text('¿Estás seguro de que deseas aprobar este comercio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí iría la lógica para aprobar el comercio
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$merchantName ha sido aprobado')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60023)),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );
  }
}

// Página de gestión de repartidores
class _DriversManagementPage extends StatelessWidget {
  const _DriversManagementPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Página de gestión de repartidores en construcción',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

// Widget para las tarjetas de estadísticas
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para los elementos de actividad reciente
class _ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE60023).withOpacity(0.2),
        child: Icon(icon, color: const Color(0xFFE60023)),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(time, style: TextStyle(color: Colors.grey[600])),
    );
  }
}

// Widget para los elementos de la lista de comerciantes
class _MerchantListItem extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback onApprove;
  final bool isApproved;

  const _MerchantListItem({
    required this.name,
    required this.status,
    required this.onApprove,
    this.isApproved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.store),
        ),
        title: Text(name),
        subtitle: Text('Estado: $status'),
        trailing: isApproved
            ? const Icon(Icons.verified, color: Colors.green)
            : ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aprobar'),
              ),
      ),
    );
  }
}
