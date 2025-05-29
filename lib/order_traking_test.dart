import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/ubication/Delivery_trancking_Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DeliveryTrackingScreen(),
    );
  }
}
