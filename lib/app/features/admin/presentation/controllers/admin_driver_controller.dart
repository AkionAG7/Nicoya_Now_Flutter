import 'package:flutter/material.dart';

import '../../../../../app/core/error/failures.dart';
import '../../domain/entities/driver/driver.dart';
import '../../domain/usecases/driver/driver_usecases.dart';

enum AdminDriverState {
  initial,
  loading,
  loaded,
  error,
}

/// Controller for managing drivers in the admin panel
class AdminDriverController extends ChangeNotifier {
  final GetAllDriversUseCase _getAllDriversUseCase;
  final ApproveDriverUseCase _approveDriverUseCase;
  final RejectDriverUseCase _rejectDriverUseCase;

  AdminDriverController({
    required GetAllDriversUseCase getAllDriversUseCase,
    required ApproveDriverUseCase approveDriverUseCase,
    required RejectDriverUseCase rejectDriverUseCase,
  }) : _getAllDriversUseCase = getAllDriversUseCase,
       _approveDriverUseCase = approveDriverUseCase,
       _rejectDriverUseCase = rejectDriverUseCase;

  AdminDriverState _state = AdminDriverState.initial;
  List<Driver> _drivers = [];
  String? _error;

  AdminDriverState get state => _state;
  List<Driver> get drivers => _drivers;
  String? get error => _error;

  /// Load all drivers from the database
  Future<void> loadDrivers() async {
    print('AdminDriverController: Starting to load drivers');
    _state = AdminDriverState.loading;
    _error = null;
    notifyListeners();

    try {
      print('AdminDriverController: Calling getAllDriversUseCase');
      final result = await _getAllDriversUseCase.call();
      
      print('AdminDriverController: Got result from use case: $result');
      result.fold(
        (failure) {
          print('AdminDriverController: Got failure: ${failure.runtimeType} - ${failure.message}');
          _error = _getFailureMessage(failure);
          _state = AdminDriverState.error;
        },
        (drivers) {
          print('AdminDriverController: Got ${drivers.length} drivers: $drivers');
          _drivers = drivers;
          _state = AdminDriverState.loaded;
        },
      );
    } catch (e) {
      print('AdminDriverController: Caught unexpected error: $e');
      _error = 'Error inesperado: $e';
      _state = AdminDriverState.error;
    }

    print('AdminDriverController: Final state is $_state, error: $_error, drivers count: ${_drivers.length}');
    notifyListeners();
  }

  /// Filter drivers by search query and status
  List<Driver> getFilteredDrivers(String query, {bool? isApproved}) {
    List<Driver> filteredList = _drivers;
    
    // First filter by approval status if specified
    if (isApproved != null) {
      filteredList = filteredList.where((driver) => driver.isVerified == isApproved).toList();
    }
    
    // Then filter by search query if provided
    if (query.isNotEmpty) {
      filteredList = filteredList.where((driver) {
        return driver.driverId.toLowerCase().contains(query.toLowerCase()) ||
               driver.vehicleType.toLowerCase().contains(query.toLowerCase()) ||
               (driver.licenseNumber?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }
    
    return filteredList;
  }

  /// Get pending drivers (not verified)
  List<Driver> getPendingDrivers() {
    return _drivers.where((driver) => !driver.isVerified).toList();
  }

  /// Get approved drivers (verified)
  List<Driver> getApprovedDrivers() {
    return _drivers.where((driver) => driver.isVerified).toList();
  }

  /// Get failure message from Failure object
  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor. Intenta nuevamente.';
    } else if (failure is NetworkFailure) {
      return 'Error de conexión. Verifica tu internet.';
    } else {
      return 'Error desconocido. Intenta nuevamente.';
    }
  }

  /// Approve a driver by ID
  Future<bool> approveDriver(String driverId) async {
    try {
      final result = await _approveDriverUseCase.call(driverId);
      return result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          notifyListeners();
          return false;
        },
        (approvedDriver) {
          // Update the driver in the local list
          final index = _drivers.indexWhere((d) => d.driverId == driverId);
          if (index != -1) {
            _drivers[index] = approvedDriver;
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  /// Reject a driver by ID
  Future<bool> rejectDriver(String driverId) async {
    try {
      final result = await _rejectDriverUseCase.call(driverId);
      return result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          notifyListeners();
          return false;
        },
        (rejectedDriver) {
          // Update the driver in the local list
          final index = _drivers.indexWhere((d) => d.driverId == driverId);
          if (index != -1) {
            _drivers[index] = rejectedDriver;
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  /// Refresh drivers data
  Future<void> refresh() async {
    await loadDrivers();
  }
}
