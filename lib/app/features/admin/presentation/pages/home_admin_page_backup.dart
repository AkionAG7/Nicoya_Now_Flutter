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
class _MerchantsManagementPage extends StatefulWidget {
  const _MerchantsManagementPage();

  @override
  State<_MerchantsManagementPage> createState() =>
      _MerchantsManagementPageState();
}

class _MerchantsManagementPageState extends State<_MerchantsManagementPage>
    with SingleTickerProviderStateMixin {
  late AdminMerchantController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = locator<AdminMerchantController>();
    _controller.loadMerchants();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Add a delayed debug print to check controller state
    Future.delayed(const Duration(seconds: 3), () {
      //ignore: avoid_print
      print("DEBUG CONTROLLER STATE AFTER 3s: ");
      //ignore: avoid_print
      print("State: ${_controller.state}");
      //ignore: avoid_print
      print("Error: ${_controller.error}");
      //ignore: avoid_print
      print("Merchants count: ${_controller.merchants.length}");
      if (_controller.merchants.isNotEmpty) {
        //ignore: avoid_print
        print("First merchant: ${_controller.merchants.first}");
      }
    });
  }

  void _handleTabChange() {
    // Force UI to update when tab changes
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Comerciantes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tab bar for filtering by approval status
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Por Aprobar'), Tab(text: 'Aprobados')],
              labelColor: const Color(0xFFE60023),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFE60023),
            ),

            const SizedBox(height: 16),

            // Filtros o búsqueda
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
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
              child: Consumer<AdminMerchantController>(
                builder: (context, controller, child) {
                  if (controller.state == AdminMerchantState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.state == AdminMerchantState.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.error ?? 'Error desconocido',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.refresh(),
                            child: const Text('Reintentar'),
                          ),
                          const SizedBox(height: 16),
                          // Debug button
                          ElevatedButton(
                            onPressed: () {
                              //ignore: avoid_print
                              print("DEBUG CONTROLLER INFO:");
                              //ignore: avoid_print
                              print("State: ${controller.state}");
                              //ignore: avoid_print
                              print("Error: ${controller.error}");
                              //ignore: avoid_print
                              print(
                                "Merchants count: ${controller.merchants.length}",
                              );

                              // Print raw network response
                              locator<AdminMerchantController>()
                                  .loadMerchants();
                            },
                            child: const Text('Debug Info (Check Console)'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Use tab index to determine approval status filter
                  final isApproved =
                      _tabController.index == 1; // 0=pending, 1=approved
                  final filteredMerchants = controller.getFilteredMerchants(
                    _searchQuery,
                    isApproved: isApproved,
                  );

                  if (filteredMerchants.isEmpty) {
                    return Center(
                      child: Text(
                        isApproved
                            ? 'No se encontraron comerciantes aprobados'
                            : 'No se encontraron comerciantes pendientes de aprobación',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.refresh(),
                    child: ListView.builder(
                      itemCount: filteredMerchants.length,
                      itemBuilder: (context, index) {
                        final merchant = filteredMerchants[index];
                        return _MerchantListItem(
                          name: merchant.businessName,
                          status:
                              merchant.isVerified ? 'Aprobado' : 'Pendiente',
                          onApprove:
                              () => _showApprovalDialog(
                                context,
                                merchant.businessName,
                                merchant.merchantId,
                              ),
                          isApproved: merchant.isVerified,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApprovalDialog(
    BuildContext context,
    String merchantName,
    String merchantId,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Aprobar $merchantName'),
            content: const Text(
              '¿Estás seguro de que deseas aprobar este comercio?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Llamar al método de aprobación del controlador
                  try {
                    await _controller.approveMerchant(merchantId);
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('$merchantName ha sido aprobado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error al aprobar $merchantName: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                ),
                child: const Text('Aprobar'),
              ),
            ],
          ),
    );
  }
}

// Página de gestión de repartidores
class _DriversManagementPage extends StatefulWidget {
  const _DriversManagementPage();

  @override
  State<_DriversManagementPage> createState() => _DriversManagementPageState();
}

class _DriversManagementPageState extends State<_DriversManagementPage>
    with SingleTickerProviderStateMixin {
  late AdminDriverController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = locator<AdminDriverController>();
    _controller.loadDrivers();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Add a delayed debug print to check controller state
    Future.delayed(const Duration(seconds: 3), () {
      //ignore: avoid_print
      print("DEBUG DRIVER CONTROLLER STATE AFTER 3s: ");
      //ignore: avoid_print
      print("State: ${_controller.state}");
      //ignore: avoid_print
      print("Error: ${_controller.error}");
      //ignore: avoid_print
      print("Drivers count: ${_controller.drivers.length}");
      if (_controller.drivers.isNotEmpty) {
        //ignore: avoid_print
        print("First driver: ${_controller.drivers.first}");
      }
    });
  }

  void _handleTabChange() {
    // Force UI to update when tab changes
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión de Repartidores',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Tab bar for filtering by approval status
            TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'Por Aprobar'), Tab(text: 'Aprobados')],
              labelColor: const Color(0xFFE60023),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFE60023),
            ),

            const SizedBox(height: 16),

            // Filtros o búsqueda
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar repartidor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lista de repartidores
            Expanded(
              child: Consumer<AdminDriverController>(
                builder: (context, controller, child) {
                  if (controller.state == AdminDriverState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.state == AdminDriverState.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.error ?? 'Error desconocido',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.refresh(),
                            child: const Text('Reintentar'),
                          ),
                          const SizedBox(height: 16),
                          // Debug button
                          ElevatedButton(
                            onPressed: () {
                              //ignore: avoid_print
                              print("DEBUG DRIVER CONTROLLER INFO:");
                              //ignore: avoid_print
                              print("State: ${controller.state}");
                              //ignore: avoid_print
                              print("Error: ${controller.error}");
                              //ignore: avoid_print
                              print(
                                "Drivers count: ${controller.drivers.length}",
                              );

                              // Print raw network response
                              locator<AdminDriverController>().loadDrivers();
                            },
                            child: const Text('Debug Info (Check Console)'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Use tab index to determine approval status filter
                  final isApproved =
                      _tabController.index == 1; // 0=pending, 1=approved
                  final filteredDrivers = controller.getFilteredDrivers(
                    _searchQuery,
                    isApproved: isApproved,
                  );

                  if (filteredDrivers.isEmpty) {
                    return Center(
                      child: Text(
                        isApproved
                            ? 'No se encontraron repartidores aprobados'
                            : 'No se encontraron repartidores pendientes de aprobación',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => controller.refresh(),
                    child: ListView.builder(
                      itemCount: filteredDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = filteredDrivers[index];
                        return _DriverListItem(
                          driverId: driver.driverId,
                          vehicleType: driver.vehicleType,
                          licenseNumber: driver.licenseNumber ?? 'N/A',
                          status: driver.isVerified ? 'Aprobado' : 'Pendiente',
                          onApprove:
                              () => _showDriverApprovalDialog(
                                context,
                                driver.driverId,
                              ),
                          onReject:
                              () => _showDriverRejectionDialog(
                                context,
                                driver.driverId,
                              ),
                          isApproved: driver.isVerified,
                          docsUrl: driver.docsUrl,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriverApprovalDialog(BuildContext context, String driverId) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Aprobar Repartidor'),
            content: const Text(
              '¿Estás seguro de que deseas aprobar este repartidor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Llamar al método de aprobación del controlador
                  try {
                    final success = await _controller.approveDriver(driverId);
                    if (success) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Repartidor aprobado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error al aprobar repartidor: ${_controller.error}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error al aprobar repartidor: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                ),
                child: const Text('Aprobar'),
              ),
            ],
          ),
    );
  }

  void _showDriverRejectionDialog(BuildContext context, String driverId) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Rechazar Repartidor'),
            content: const Text(
              '¿Estás seguro de que deseas rechazar este repartidor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);

                  // Llamar al método de rechazo del controlador
                  try {
                    final success = await _controller.rejectDriver(driverId);
                    if (success) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Repartidor rechazado'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error al rechazar repartidor: ${_controller.error}',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Error al rechazar repartidor: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Rechazar'),
              ),
            ],
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
              color: Colors.grey.withAlpha(51),
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
        backgroundColor: const Color(0xFFE60023).withAlpha(51),
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
        leading: const CircleAvatar(child: Icon(Icons.store)),
        title: Text(name),
        subtitle: Text('Estado: $status'),
        trailing:
            isApproved
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

// Widget para los elementos de la lista de repartidores
class _DriverListItem extends StatelessWidget {
  final String driverId;
  final String vehicleType;
  final String licenseNumber;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isApproved;
  final String? docsUrl;

  const _DriverListItem({
    required this.driverId,
    required this.vehicleType,
    required this.licenseNumber,
    required this.status,
    required this.onApprove,
    required this.onReject,
    this.isApproved = false,
    this.docsUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              isApproved
                  ? Colors.green.withAlpha(51)
                  : Colors.orange.withAlpha(51),
          child: Icon(
            Icons.delivery_dining,
            color: isApproved ? Colors.green : Colors.orange,
          ),
        ),
        title: Text('ID: $driverId'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text('Vehículo: $vehicleType'), Text('Estado: $status')],
        ),
        trailing:
            isApproved
                ? const Icon(Icons.verified, color: Colors.green)
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onReject,
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Rechazar',
                    ),
                    IconButton(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, color: Colors.green),
                      tooltip: 'Aprobar',
                    ),
                  ],
                ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID del Repartidor', driverId),
                _buildDetailRow('Tipo de Vehículo', vehicleType),
                _buildDetailRow('Número de Licencia', licenseNumber),
                _buildDetailRow('Estado', status),
                if (docsUrl != null && docsUrl!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Documentos: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('URL de documentos: $docsUrl'),
                            ),
                          );
                        },
                        child: const Text('Ver Documentos'),
                      ),
                    ],
                  ),
                ],
                if (!isApproved) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onReject,
                          icon: const Icon(Icons.close),
                          label: const Text('Rechazar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check),
                          label: const Text('Aprobar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE60023),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
