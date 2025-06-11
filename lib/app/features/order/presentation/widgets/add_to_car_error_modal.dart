import 'package:flutter/material.dart';

Future<void> showOrderErrorModal(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Center(child: Text('Advertencia')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              color: Colors.orangeAccent,
              size: 100,
            ),

            SizedBox(height: 20),

            Text(
              'Tienes un pedido pendiente de otro comerciante, finaliza ese pedido o cancélalo para agregar productos de otros comerciantes',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 150,
            height: 50,
            child: TextButton(
              style: TextButton.styleFrom(backgroundColor: Color(0xFFF10027)),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      );
    },
  );
}
