import 'package:flutter/material.dart';

import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class ItemCart extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const ItemCart({
    super.key,
    required this.product,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  product.image_url!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  Text(
                    'Precio : ${product.price * quantity} CRC',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9B9B9B),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: onRemove,
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFf10027),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _cantidadBtn(NicoyaNowIcons.menos, onDecrement),
                      const SizedBox(width: 10),
                      Text(quantity.toString()),
                      const SizedBox(width: 10),
                      _cantidadBtn(NicoyaNowIcons.mas, onIncrement),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cantidadBtn(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFfee6e9),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 10, color: const Color(0xFFf10027)),
        ),
      ),
    );
  }
}
