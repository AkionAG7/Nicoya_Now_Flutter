import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/driver/driver.dart';

/// Página de detalle para ver toda la información de un driver
class DriverDetailPage extends StatelessWidget {
  final Driver driver;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onSuspend;

  const DriverDetailPage({
    super.key,
    required this.driver,
    this.onApprove,
    this.onReject,
    this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Repartidor'),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado y acciones
            _buildStatusCard(),
            const SizedBox(height: 16),
            
            // Información básica
            _buildInfoCard(),
            const SizedBox(height: 16),
            
            // Documentos
            _buildDocumentsCard(),
            const SizedBox(height: 16),
            
            // Ubicación
            _buildLocationCard(),
            const SizedBox(height: 16),
            
            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  driver.isVerified ? Icons.verified : Icons.pending,
                  color: driver.isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  driver.isVerified ? 'Aprobado' : 'Pendiente',
                  style: TextStyle(
                    color: driver.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Registrado: ${_formatDate(driver.createdAt)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Vehículo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID del Repartidor:', driver.driverId),
            _buildInfoRow('Tipo de Vehículo:', driver.vehicleType.toString()),
            _buildInfoRow('Número de Licencia:', driver.licenseNumber ?? 'No especificado'),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (driver.docsUrl != null && driver.docsUrl!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openDocument(driver.docsUrl!),
                icon: const Icon(Icons.description),
                label: const Text('Ver Documentos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              )
            else
              const Text(
                'No hay documentos disponibles',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (driver.currentLatitude != null && driver.currentLongitude != null) ...[
              _buildInfoRow('Latitud:', driver.currentLatitude.toString()),
              _buildInfoRow('Longitud:', driver.currentLongitude.toString()),
              if (driver.lastLocationUpdate != null)
                _buildInfoRow('Última actualización:', _formatDate(driver.lastLocationUpdate!)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _openLocation(driver.currentLatitude!, driver.currentLongitude!),
                icon: const Icon(Icons.map),
                label: const Text('Ver en Mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else
              const Text(
                'Ubicación no disponible',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!driver.isVerified && onApprove != null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onApprove!();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Aprobar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (!driver.isVerified && onReject != null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onReject!();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Rechazar'),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (driver.isVerified && onSuspend != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onSuspend!();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Suspender'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openLocation(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
