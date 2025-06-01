// lib/app/features/order/presentation/pages/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailPage extends StatelessWidget {
  final String orderId;
  const OrderDetailPage({required this.orderId, Key? key}) : super(key: key);

  /// Carga datos de la orden incluyendo dirección y productos
  Future<Map<String, dynamic>> _loadData() async {
    final client = Supabase.instance.client;

    final result = await client
        .from('order')
        .select('''
          order_id,
          customer_id,
          merchant_id,
          total,
          placed_at,
          status,
          delivery_address:delivery_address_id ( street ),
          items:order_item (
            order_item_id,
            quantity,
            product:product_id ( name, price )
          )
        ''')
        .eq('order_id', orderId)
        .maybeSingle();

    if (result == null) throw Exception('No se encontró la orden $orderId');
    return Map<String, dynamic>.from(result as Map);
  }

  /// Actualiza el campo `status` de la orden a `newStatus`
  Future<void> _updateOrderStatus(
    BuildContext context,
    String newStatus,
  ) async {
    debugPrint('>>> _updateOrderStatus llamado con orderId = $orderId y newStatus = $newStatus');
    try {
      final res = await Supabase.instance.client
          .from('order')
          .update({ 'status': newStatus })
          .eq('order_id', orderId)
          .select();

      // res is a PostgrestList (List<dynamic>)
      final updatedRows = res as List<dynamic>?;
      if (updatedRows == null || updatedRows.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La orden no fue encontrada o no se pudo actualizar.'),
          ),
        );
        return;
      }

      final updatedStatus = (updatedRows.first as Map<String, dynamic>)['status'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "$updatedStatus"')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Excepción: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Orden')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadData(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final data = snap.data!;
          final street = (data['delivery_address'] as Map<String, dynamic>?)?['street']
              as String? ?? '-';
          final items = data['items'] as List<dynamic>? ?? [];
          final currentStatus = data['status'] as String? ?? 'pending';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Cliente: ${data['customer_id']}'),
              ),
              ListTile(
                leading: const Icon(Icons.store),
                title: Text('Comerciante: ${data['merchant_id']}'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: Text('Dirección: $street'),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: Text(
                  'Total: \$${(data['total'] as num).toDouble().toStringAsFixed(2)}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  'Fecha: ${DateTime.parse(data['placed_at'] as String).toLocal()}',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text('Estado: ${currentStatus.toUpperCase()}'),
              ),

              const Divider(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Productos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...items.map((item) {
                final m = item as Map<String, dynamic>;
                final prod = m['product'] as Map<String, dynamic>;
                final qty = m['quantity'] as int;
                return ListTile(
                  title: Text(prod['name'] as String),
                  subtitle: Text('Cantidad: $qty'),
                  trailing: Text(
                    '\$${(prod['price'] as num).toDouble().toStringAsFixed(2)}',
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),
              const Divider(height: 32),

              // Botones dinámicos según el estado de la orden
              if (currentStatus == 'pending') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Cambia de "pending" a "accepted"
                        _updateOrderStatus(context, 'accepted');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text('Aceptar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Cambia de "pending" a "cancelled"
                        _updateOrderStatus(context, 'cancelled');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(120, 40),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ] else if (currentStatus == 'accepted') ...[
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Una vez aceptada, el comerciante puede pasarla a "in_process"
                      _updateOrderStatus(context, 'in_process');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(120, 40),
                    ),
                    child: const Text('Procesar'),
                  ),
                ),
              ] else ...[
                ElevatedButton(
                    onPressed: currentStatus == 'pending' || currentStatus == 'accepted' || currentStatus == 'in_process'
                        ? () {
                            // Cambia a "cancelled"
                            _updateOrderStatus(context, 'cancelled');
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(120, 40),
                    ),
                    child: const Text('Cancelar'),
                  ),
                const SizedBox.shrink(),
              ],
            ],
          );
        },
      ),
    );
  }
}
