import '../../models/driver_model.dart';

/// Abstract class for driver remote data source
abstract class DriverRemoteDataSource {
  /// Get all drivers from the remote source
  Future<List<DriverModel>> getAllDrivers();
  
  /// Get a driver by ID from the remote source
  Future<DriverModel> getDriverById(String driverId);
  
  /// Set a driver's verification status to true
  Future<DriverModel> approveDriver(String driverId);
  
  /// Set a driver's verification status to false
  Future<DriverModel> rejectDriver(String driverId);
  
  /// Create a new driver in the remote source
  Future<DriverModel> createDriver(DriverModel driver);
  
  /// Update an existing driver in the remote source
  Future<DriverModel> updateDriver(DriverModel driver);
  
  /// Delete a driver from the remote source
  Future<bool> deleteDriver(String driverId);
}

/// Implementation of [DriverRemoteDataSource] that uses Supabase
class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final dynamic supabase; // Replace with actual Supabase client type
  
  DriverRemoteDataSourceImpl({required this.supabase});
  
  @override
  Future<List<DriverModel>> getAllDrivers() async {
    try {
      final response = await supabase.from('driver').select('*');
      return (response as List).map((json) => DriverModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get drivers: $e');
    }
  }
  
  @override
  Future<DriverModel> getDriverById(String driverId) async {
    try {
      final response = await supabase
          .from('driver')
          .select('*')
          .eq('driver_id', driverId)
          .single();
      return DriverModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get driver: $e');
    }
  }
  
  @override
  Future<DriverModel> approveDriver(String driverId) async {
    try {
      final response = await supabase
          .from('driver')
          .update({'is_verified': true})
          .eq('driver_id', driverId)
          .select()
          .single();
      return DriverModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to approve driver: $e');
    }
  }
  
  @override
  Future<DriverModel> rejectDriver(String driverId) async {
    try {
      final response = await supabase
          .from('driver')
          .update({'is_verified': false})
          .eq('driver_id', driverId)
          .select()
          .single();
      return DriverModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to reject driver: $e');
    }
  }
  
  @override
  Future<DriverModel> createDriver(DriverModel driver) async {
    try {
      final response = await supabase
          .from('driver')
          .insert(driver.toJson())
          .select()
          .single();
      return DriverModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create driver: $e');
    }
  }
  
  @override
  Future<DriverModel> updateDriver(DriverModel driver) async {
    try {
      final response = await supabase
          .from('driver')
          .update(driver.toJson())
          .eq('driver_id', driver.driverId)
          .select()
          .single();
      return DriverModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }
  
  @override
  Future<bool> deleteDriver(String driverId) async {
    try {
      await supabase
          .from('driver')
          .delete()
          .eq('driver_id', driverId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete driver: $e');
    }
  }
}
