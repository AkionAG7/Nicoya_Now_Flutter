import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/merchant/merchant.dart';

/// Página de detalle para ver toda la información de un merchant
class MerchantDetailPage extends StatelessWidget {
  final Merchant merchant;
  final VoidCallback? onApprove;
  final VoidCallback? onSuspend;

  const MerchantDetailPage({
    super.key,
    required this.merchant,
    this.onApprove,
    this.onSuspend,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Comercio'),
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
            
            // Logo y documentos
            _buildMediaCard(),
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
                  merchant.isVerified ? Icons.verified : Icons.pending,
                  color: merchant.isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  merchant.isVerified ? 'Aprobado' : 'Pendiente',
                  style: TextStyle(
                    color: merchant.isVerified ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Registrado: ${_formatDate(merchant.createdAt)}',
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
              'Información del Negocio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID del Comercio:', merchant.merchantId),
            _buildInfoRow('Nombre del Negocio:', merchant.businessName),
            _buildInfoRow('Categoría:', merchant.businessCategory),
            if (merchant.address != null)
              _buildInfoRow('Dirección:', merchant.address!),
            if (merchant.phoneNumber != null)
              _buildInfoRow('Teléfono:', merchant.phoneNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo y Documentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Logo
            if (merchant.logoUrl != null && merchant.logoUrl!.isNotEmpty) ...[
              const Text('Logo del Negocio:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    merchant.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error, size: 50);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Documentos
            if (merchant.docsUrl != null && merchant.docsUrl!.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _openDocument(merchant.docsUrl!),
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
            if (merchant.address != null && merchant.address!.isNotEmpty) ...[
              _buildInfoRow('Dirección:', merchant.address!),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _searchLocation(merchant.address!),
                icon: const Icon(Icons.map),
                label: const Text('Buscar en Mapa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else
              const Text(
                'Dirección no disponible',
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
                if (!merchant.isVerified && onApprove != null) ...[
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
                if (merchant.isVerified && onSuspend != null)
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

  Future<void> _searchLocation(String address) async {
    final query = Uri.encodeComponent(address);
    final uri = Uri.parse('https://www.google.com/maps/search/$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
