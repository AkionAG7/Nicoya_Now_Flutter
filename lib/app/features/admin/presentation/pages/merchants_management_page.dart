import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/di/service_locator.dart';
import '../controllers/admin_merchant_controller.dart';
import '../widgets/merchant_list_item.dart';
import 'merchant_detail_page.dart';

/// Página de gestión de comerciantes
class MerchantsManagementPage extends StatefulWidget {
  const MerchantsManagementPage({super.key});

  @override
  State<MerchantsManagementPage> createState() =>
      _MerchantsManagementPageState();
}

class _MerchantsManagementPageState extends State<MerchantsManagementPage>
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
                          const SizedBox(height: 16),                          ElevatedButton(
                            onPressed: () => controller.refresh(),
                            child: const Text('Reintentar'),
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
                        final merchant = filteredMerchants[index];                        return MerchantListItem(
                          name: merchant.businessName,
                          status:
                              merchant.isVerified ? 'Aprobado' : 'Pendiente',
                          onApprove:
                              () => _showApprovalDialog(
                                context,
                                merchant.businessName,
                                merchant.merchantId,
                              ),
                          onUnapprove: merchant.isVerified 
                              ? () => _showUnapprovalDialog(
                                  context,
                                  merchant.businessName,
                                  merchant.merchantId,
                                )
                              : null,
                          onViewDetails: () => _navigateToMerchantDetail(merchant),
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
    );  }

  void _navigateToMerchantDetail(merchant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MerchantDetailPage(
          merchant: merchant,
          onApprove: !merchant.isVerified
              ? () async {
                  Navigator.pop(context);
                  try {
                    await _controller.approveMerchant(merchant.merchantId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${merchant.businessName} ha sido aprobado'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al aprobar ${merchant.businessName}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
          onSuspend: merchant.isVerified
              ? () async {
                  Navigator.pop(context);
                  try {
                    final success = await _controller.unapproveMerchant(merchant.merchantId);
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${merchant.businessName} ha sido suspendido'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al suspender ${merchant.businessName}: ${_controller.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al suspender ${merchant.businessName}: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              : null,
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
  void _showUnapprovalDialog(
    BuildContext context,
    String merchantName,
    String merchantId,
  ) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Suspender $merchantName'),
        content: const Text(
          '¿Estás seguro de que deseas suspender este comercio? Esto cambiará su estado a "Pendiente".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Llamar al método de desaprobación del controlador
              try {
                final success = await _controller.unapproveMerchant(merchantId);                if (success) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('$merchantName ha sido suspendido'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error al suspender $merchantName: ${_controller.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Error al suspender $merchantName: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Suspender'),          ),
        ],
      ),
    );
  }
}
