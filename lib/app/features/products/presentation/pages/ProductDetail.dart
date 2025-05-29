import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/address/domain/entities/address.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_item_datasource.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int cantidad = 1;

  void incrementarCantidad() {
    setState(() {
      cantidad++;
    });
  }

  void decrementarCantidad() {
    setState(() {
      if (cantidad > 1) {
        // Evita que la cantidad sea menor que 1
        cantidad--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                child: Image.network(product.image_url!, fit: BoxFit.cover),
              ),

              // El appbar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white, size: 40),
                ),
              ),

              // efecto de borde abajo de la imagen
              Positioned(
                left: 0,
                right: 0,
                top: MediaQuery.of(context).size.height * 0.45,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
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
                              onPressed: () => print('dad'),
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
                              onPressed: () => print('dad'),
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
                              onPressed: () => decrementarCantidad(),
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
                              onPressed: () => incrementarCantidad(),
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

                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final supa = Supabase.instance.client;
                        final OrderItemDatasource = OrderItemDatasourceImpl(
                          supa: supa,
                        );
                        final costumerId = supa.auth.currentUser?.id;
                        if (costumerId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Por favor, inicia sesión')),
                          );
                          return;
                        }

                        final addressReponse =
                            await supa
                                .from('address')
                                .select()
                                .eq('user_id', costumerId)
                                .limit(1)
                                .maybeSingle();
                        if (addressReponse == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No tienes direcciones registradas',
                              ),
                            ),
                          );
                          return;
                        }
                        final address = Address(
                          address_id: addressReponse['address_id'],
                          user_id: addressReponse['user_id'],
                          street: addressReponse['street'],
                          district: addressReponse['district'],
                          lat: addressReponse['lat'],
                          Ing: addressReponse['Ing'],
                          note: addressReponse['note'],
                          created_at: addressReponse['created_at'],
                        );
                        await OrderItemDatasource.addProductToOrder(
                          costumerId,
                          product,
                          cantidad,
                          address,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFf10027),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Agregar al carrito',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
