import 'package:flutter/material.dart';

/// Widget para los elementos de la lista de repartidores
class DriverListItem extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onUnapprove;
  final VoidCallback? onViewDetails;
  final bool isApproved;
  const DriverListItem({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.onApprove,
    this.onReject,
    this.onUnapprove,
    this.onViewDetails,
    this.isApproved = false,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFE60023),
                  child: Icon(Icons.delivery_dining, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isApproved)
                  const Icon(Icons.verified, color: Colors.green, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estado: $status',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onViewDetails != null) ...[
                  OutlinedButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('Ver más'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(80, 32),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (!isApproved && onReject != null) ...[
                  OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(80, 32),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (isApproved && onUnapprove != null)
                  ElevatedButton(
                    onPressed: onUnapprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(80, 32),
                    ),
                    child: const Text('Suspender'),
                  )
                else if (!isApproved)
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE60023),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(80, 32),
                    ),
                    child: const Text('Aprobar'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
