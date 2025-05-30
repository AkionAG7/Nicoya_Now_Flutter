import 'package:flutter/material.dart';

class Pago extends StatefulWidget {
  const Pago({ Key? key }) : super(key: key);

  @override
  _PagoState createState() => _PagoState();
}

class _PagoState extends State<Pago> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text('Confirma tu orden'),
      ),

      body: Center(
        child: Container(
          child: Column(
            children: [
              Text('Método de pago'),
              
            ],
          ),
        ),
      ),

      
    );
  }
}