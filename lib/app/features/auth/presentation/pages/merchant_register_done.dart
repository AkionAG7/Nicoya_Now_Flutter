// lib/app/features/auth/presentation/pages/merchant_register_done.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class MerchantPendingPage extends StatefulWidget {
  const MerchantPendingPage({super.key});

  @override
  State<MerchantPendingPage> createState() => _MerchantPendingPageState();
}

class _MerchantPendingPageState extends State<MerchantPendingPage> {
  @override
  void initState() {
    super.initState();
    // Show message for longer to give user time to read
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login_page, // Changed from preLogin to login_page for better UX    
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.store, size: 80, color: Colors.orange),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '¡Gracias! Tu negocio está en proceso de verificación. Te notificaremos por correo cuando sea aprobado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
}
