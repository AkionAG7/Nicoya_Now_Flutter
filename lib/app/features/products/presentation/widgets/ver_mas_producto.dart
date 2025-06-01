import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/enums/ValorVerMas_enum.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class VerMasProducto extends StatelessWidget {
  const VerMasProducto({super.key, required this.title, required this.valor});

  final String title;
  final valorVerMas valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, Routes.food_filter, arguments: valor);
          },
          child: Text(
            'ver más',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xffd72a23),
            ),
          ),
        ),
      ],
    );
  }
}
