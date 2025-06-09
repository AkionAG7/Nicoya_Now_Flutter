import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

/// Service class for driver order-related operations
class DriverOrderService {
  static final _supabase = Supabase.instance.client;
  
  /// Get current driver's active orders
  static Future<List<Map<String, dynamic>>> getActiveOrders() async {
    try {
      final response = await _supabase
          .from('current_driver_orders')
          .select();      // la vista ya trae JSON anidado y filtra estados
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e, s) {
      debugPrint('Error fetching active orders: $e\n$s');
      return [];
    }
  }

  /// Update order parsing to handle nested JSON objects
  static Map<String, dynamic> parseOrderData(Map<String, dynamic> order) {
    // Process nested objects safely
    order['merchantName'] = order['merchant']?['business_name'] ?? 'Comercio';
    order['customerName'] = order['customer']?['first_name'] ?? 'Cliente';
    order['delivery_lat'] = order['delivery_address']?['lat'];
    order['delivery_lng'] = order['delivery_address']?['lng'];
    
    return order;
  }
  
  /// Mark an order as delivered
  static Future<void> markDelivered(String orderId) async {
    await _supabase.rpc('mark_order_delivered', params: {
      'p_driver_id': _supabase.auth.currentUser!.id,
      'p_order_id' : orderId,
    });
  }
}
