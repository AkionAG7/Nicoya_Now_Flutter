import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';

class ProfileTabWidget extends StatelessWidget {
  final DriverController controller;
  final VoidCallback onSignOut;

  const ProfileTabWidget({
    super.key,
    required this.controller,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    // Format driver data for display
    final driverData = controller.currentDriverData;
    final String firstName = driverData?['first_name'] ?? '';
    final String lastName1 = driverData?['last_name1'] ?? '';
    final String lastName2 = driverData?['last_name2'] ?? '';
    final String phone = driverData?['phone'] ?? '';
    final String vehicleType = driverData?['vehicle_type'] ?? '';
    final String licenseNumber = driverData?['license_number'] ?? '';
    final bool isVerified = driverData?['is_verified'] ?? false;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile header
            CircleAvatar(
              backgroundColor: const Color(0xFFE60023),
              radius: 50,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              '$firstName $lastName1 $lastName2',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Repartidor ${isVerified ? 'Verificado' : 'Pendiente de verificación'}',
              style: TextStyle(
                fontSize: 16,
                color: isVerified ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Profile details
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileField('Teléfono', phone),
                    _buildProfileField('Tipo de vehículo', vehicleType),
                    _buildProfileField('Número de licencia', licenseNumber),
                    _buildProfileField(
                      'Estado',
                      isVerified ? 'Verificado' : 'Pendiente de verificación',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Account actions
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: const Color(0xFFE60023),
                      ),
                      title: Text('Ayuda'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Show help dialog
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.red),
                      title: Text('Cerrar sesión'),
                      onTap: onSignOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
