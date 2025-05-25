import 'package:flutter/material.dart';

class HomeMerchantPage extends StatefulWidget {
  const HomeMerchantPage({Key? key}) : super(key: key);

  @override
  _HomeMerchantPageState createState() => _HomeMerchantPageState();
}

class _HomeMerchantPageState extends State<HomeMerchantPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Merchant'),
        backgroundColor: const Color(0xFFE60023),
      ),
      body: const Center(
        child: Text(
          '¡Has llegado a HomeMerchantPage!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
