import 'package:flutter/material.dart';
import 'dart:math' as math;

class AvailableOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAccept;

  const AvailableOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
  });
  @override
  Widget build(BuildContext context) {
    // Extract order information safely from the structure of available_orders_view
    final String orderId = order['order_id']?.toString() ?? 'Sin ID';
    
    // Merchant info
    final merchant = order['merchant'];
    final String merchantName = merchant != null ? merchant['name']?.toString() ?? 'Comercio desconocido' : 'Comercio desconocido';
    
    final String total = order['total']?.toString() ?? '0';
    
    // Customer info
    final customer = order['customer'];
    final String firstName = customer != null ? customer['first_name']?.toString() ?? '' : '';
    final String lastName = customer != null ? customer['last_name']?.toString() ?? '' : '';
    final String customerName = ('$firstName $lastName').trim().isEmpty ? 'Cliente' : '$firstName $lastName';
    
    // Address info
    final deliveryAddress = order['delivery_address'];
    final String addressText = deliveryAddress != null
        ? '${deliveryAddress['street'] ?? ''} ${deliveryAddress['city'] ?? ''}'
        : 'Dirección no disponible';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        merchantName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'ID: ${orderId.substring(0, math.min(8, orderId.length))}...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₡$total',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  customerName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    addressText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Aceptar pedido'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
