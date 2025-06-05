import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum DriverState {
  initial,
  loading,
  loaded,
  error,
}

class DriverController extends ChangeNotifier {
  final SupabaseClient _supabase;
  
  DriverState _state = DriverState.initial;
  String? _error;
  
  Map<String, dynamic>? _currentDriverData;
  List<Map<String, dynamic>> _activeOrders = [];
  
  DriverController({required SupabaseClient supabase}) : _supabase = supabase;
  
  DriverState get state => _state;
  String? get error => _error;
  Map<String, dynamic>? get currentDriverData => _currentDriverData;
  List<Map<String, dynamic>> get activeOrders => _activeOrders;
  
  /// Loads the current driver's data from the database
  Future<void> loadDriverData() async {
    _state = DriverState.loading;
    _error = null;
    notifyListeners();
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        _error = 'Usuario no autenticado';
        _state = DriverState.error;
        notifyListeners();
        return;
      }
      
      // Get driver data
      final response = await _supabase
          .from('driver')
          .select()
          .eq('driver_id', userId)
          .single();
      
      _currentDriverData = response;
      
      // Get profile data
      final profileResponse = await _supabase
          .from('profile')
          .select()
          .eq('user_id', userId)
          .single();
      
      // Merge profile data with driver data
      _currentDriverData = {
        ..._currentDriverData!,
        'first_name': profileResponse['first_name'],
        'last_name1': profileResponse['last_name1'],
        'last_name2': profileResponse['last_name2'],
        'phone': profileResponse['phone'],
      };
      
      _state = DriverState.loaded;
      notifyListeners();
      
      // Load active orders after loading driver data
      await loadActiveOrders();
    } catch (e) {
      _state = DriverState.error;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Loads active orders for the current driver
  Future<void> loadActiveOrders() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        return;
      }
      
      // Get orders assigned to this driver that are active
      // This uses the current_driver_orders view for better order data
      final response = await _supabase
          .from('current_driver_orders')
          .select('*, customer:customer_id(*), merchant:merchant_id(*), delivery_address:delivery_address_id(*)')
          .filter('status', 'in', ['assigned', 'picked_up', 'on_way']);
      
      _activeOrders = List<Map<String, dynamic>>.from(response);
      
      // Enrich the data with additional information needed for tracking
      for (var i = 0; i < _activeOrders.length; i++) {
        var order = _activeOrders[i];
        
        // Add delivery coordinates from the address if available
        if (order.containsKey('delivery_address') && order['delivery_address'] != null) {
          order['delivery_latitude'] = order['delivery_address']['latitude'] ?? 0.0;
          order['delivery_longitude'] = order['delivery_address']['longitude'] ?? 0.0;
        }
        
        // Get order assignment details
        try {
          final assignmentResponse = await _supabase
              .from('order_assignment')
              .select()
              .eq('order_id', order['order_id'])
              .eq('driver_id', userId)
              .maybeSingle();
              
          if (assignmentResponse != null) {
            order['assigned_at'] = assignmentResponse['assigned_at'];
            order['picked_up_at'] = assignmentResponse['picked_up_at'];
            order['delivered_at'] = assignmentResponse['delivered_at'];
          }
        } catch (e) {
          //ignore: avoid_print
          print('Error fetching assignment for order ${order['order_id']}: $e');
        }
      }
      
      notifyListeners();
    } catch (e) {
      //ignore: avoid_print
      print('Error loading active orders: $e');
    }
  }
  
  /// Update driver availability status
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        return;
      }
      
      await _supabase
          .from('driver')
          .update({'is_available': isAvailable})
          .eq('driver_id', userId);
      
      if (_currentDriverData != null) {
        _currentDriverData!['is_available'] = isAvailable;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar disponibilidad: $e';
      notifyListeners();
    }
  }
  
  /// Update driver's current location
  Future<void> updateLocation(double latitude, double longitude) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        return;
      }
      
      await _supabase
          .from('driver')
          .update({
            'current_latitude': latitude,
            'current_longitude': longitude,
            'last_location_update': DateTime.now().toIso8601String(),
          })
          .eq('driver_id', userId);
    } catch (e) {
      //ignore: avoid_print
      print('Error updating location: $e');
    }
  }
  
  /// Accept a new order
  Future<bool> acceptOrder(String orderId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        _error = 'Usuario no autenticado';
        notifyListeners();
        return false;
      }
      
      // Update order status and assign driver
      await _supabase
          .from('order')
          .update({
            'status': 'assigned',
          })
          .eq('order_id', orderId);
          
      // Create order assignment record
      await _supabase
          .from('order_assignment')
          .insert({
            'order_id': orderId,
            'driver_id': userId,
            'assigned_at': DateTime.now().toIso8601String(),
          });
      
      // Reload active orders
      await loadActiveOrders();
      return true;
    } catch (e) {
      _error = 'Error al aceptar orden: $e';
      notifyListeners();
      return false;
    }
  }
  
  /// Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        _error = 'Usuario no autenticado';
        notifyListeners();
        return false;
      }
      
      // Update order status
      await _supabase
          .from('order')
          .update({'status': status})
          .eq('order_id', orderId);
      
      // Update assignment record with timestamps
      final Map<String, dynamic> updates = {};
      
      switch (status) {
        case 'picked_up':
          updates['picked_up_at'] = DateTime.now().toIso8601String();
          break;
        case 'delivered':
          updates['delivered_at'] = DateTime.now().toIso8601String();
          break;
      }
      
      if (updates.isNotEmpty) {
        await _supabase
            .from('order_assignment')
            .update(updates)
            .eq('order_id', orderId)
            .eq('driver_id', userId);
      }
      
      // Reload active orders
      await loadActiveOrders();
      return true;
    } catch (e) {
      _error = 'Error al actualizar estado de orden: $e';
      notifyListeners();
      return false;
    }
  }
}
