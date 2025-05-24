// lib/app/interface/pages/auth/driver_pending.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class DriverPendingPage extends StatefulWidget {
  const DriverPendingPage({super.key});

  @override
  State<DriverPendingPage> createState() => _DriverPendingPageState();
}

class _DriverPendingPageState extends State<DriverPendingPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.preLogin,    
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
              Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '¡Gracias! Revisaremos tus documentos y te avisaremos por correo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      );
}
