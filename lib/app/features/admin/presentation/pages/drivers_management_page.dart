import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../controllers/admin_driver_controller.dart';
import '../widgets/driver_list_item.dart';

/// Página de gestión de repartidores
class DriversManagementPage extends StatefulWidget {
  const DriversManagementPage({super.key});

  @override
  State<DriversManagementPage> createState() => _DriversManagementPageState();
}

class _DriversManagementPageState extends State<DriversManagementPage> with SingleTickerProviderStateMixin {
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
      print("DEBUG DRIVER CONTROLLER STATE AFTER 3s: ");
      print("State: ${_controller.state}");
      print("Error: ${_controller.error}");
      print("Drivers count: ${_controller.drivers.length}");
      if (_controller.drivers.isNotEmpty) {
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
              tabs: const [
                Tab(text: 'Por Aprobar'),
                Tab(text: 'Aprobados'),
              ],
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
                              print("DEBUG DRIVER CONTROLLER INFO:");
                              print("State: ${controller.state}");
                              print("Error: ${controller.error}");
                              print("Drivers count: ${controller.drivers.length}");
                              
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
                  final isApproved = _tabController.index == 1; // 0=pending, 1=approved
                  final filteredDrivers = controller.getFilteredDrivers(
                    _searchQuery, 
                    isApproved: isApproved,
                  );
                  
                  if (filteredDrivers.isEmpty) {
                    return Center(
                      child: Text(isApproved 
                        ? 'No se encontraron repartidores aprobados' 
                        : 'No se encontraron repartidores pendientes de aprobación'
                      ),
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () => controller.refresh(),
                    child: ListView.builder(
                      itemCount: filteredDrivers.length,
                      itemBuilder: (context, index) {
                        final driver = filteredDrivers[index];                        return DriverListItem(
                          name: 'ID: ${driver.driverId}', // Using driverId as name since no name field exists
                          email: 'Vehículo: ${driver.vehicleType}', // Using vehicleType in email field
                          phone: driver.licenseNumber ?? 'N/A', // Using licenseNumber in phone field
                          status: driver.isVerified ? 'Aprobado' : 'Pendiente',
                          onApprove: () => _showDriverApprovalDialog(context, driver.driverId),
                          onReject: driver.isVerified ? null : () => _showDriverRejectionDialog(context, driver.driverId),
                          isApproved: driver.isVerified,
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
      builder: (context) => AlertDialog(
        title: Text('Aprobar Repartidor'),
        content: const Text('¿Estás seguro de que deseas aprobar este repartidor?'),
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
                      content: Text('Error al aprobar repartidor: ${_controller.error}'),
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60023)),
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
      builder: (context) => AlertDialog(
        title: Text('Rechazar Repartidor'),
        content: const Text('¿Estás seguro de que deseas rechazar este repartidor?'),
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
                      content: Text('Error al rechazar repartidor: ${_controller.error}'),
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
