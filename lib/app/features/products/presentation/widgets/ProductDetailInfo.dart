import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class ProductDetailInfo extends StatelessWidget {
  final Product product;
  final int cantidad;
  final VoidCallback onIcrement;
  final VoidCallback onDecrement;

  const ProductDetailInfo({
    Key? key,
    required this.product,
    required this.cantidad,
    required this.onIcrement,
    required this.onDecrement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),

            Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFFfee6e9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => print('implemetar ubiacion maybe'),
                      icon: Icon(
                        NicoyaNowIcons.ubicacion,
                        size: 20,
                        color: Color(0xFFf10027),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 15),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFFfee6e9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => print('Implementar favorito'),
                      icon: Icon(
                        Icons.favorite,
                        size: 20,
                        color: Color(0xFFf10027),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.star_half, color: Color(0xFFf10027)),
                Text('4,8 Clasificación'),
              ],
            ),

            Row(
              children: [
                Icon(NicoyaNowIcons.pedido, color: Color(0xFFf10027)),
                Text('20+ Pedidos'),
              ],
            ),
          ],
        ),

        const SizedBox(height: 30),

        Text(
          'Descripción:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        Text(
          product.description,
          style: TextStyle(fontSize: 15),
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 15),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFFfee6e9),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => onDecrement(),
                      icon: Icon(
                        NicoyaNowIcons.menos,
                        size: 15,
                        color: Color(0xFFf10027),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),
                Text(
                  '$cantidad',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFf10027),
                  ),
                ),
                const SizedBox(width: 10),

                SizedBox(
                  width: 40,
                  height: 40,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xFFfee6e9),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () => onIcrement(),
                      icon: Icon(
                        NicoyaNowIcons.mas,
                        size: 15,
                        color: Color(0xFFf10027),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Text(
              '${product.price * cantidad} CRC',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFf10027),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}
