import 'package:flutter/material.dart';

class ChickenBurguer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Image.network(
                  "https://cloudfront-us-east-1.images.arcpublishing.com/infobae/24P2OKC3RVEHRD3F2VKQ76XX7M.jpg",
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.42,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hamburguersa',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xfffee6e9),
                          ),
                          child: Icon(
                            Icons.location_pin,
                            color: Color(0xfff10027),
                            size: 25,
                          ),
                        ),

                        SizedBox(width: 15),

                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xfffee6e9),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: Color(0xfff10027),
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star_half,
                          color: Color(0xfff10027),
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '4,8 Clasificación',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.shop_2, color: Color(0xfff10027), size: 30),
                        SizedBox(width: 10),
                        Text('20+ Pedidos', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      'Deliciosa hamburguesa',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xfffee6e9),
                          ),
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 50,
                              color: Color(0xfff10027),
                            ),
                          ),
                        ),

                        SizedBox(width: 10),
                        Text(
                          '1',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xfff10027),
                          ),
                        ),
                        SizedBox(width: 10),

                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xfffee6e9),
                          ),
                          child: Text(
                            '+',
                            style: TextStyle(
                              fontSize: 30,
                              color: Color(0xfff10027),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        '12',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xfff10027),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 90,
                      child: ElevatedButton(
                        onPressed: () => print('hola'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xfff10027),
                         
                        ),
                        child: Text(
                          'Agregar al carrito',
                          style: TextStyle(fontSize: 25,
                          fontWeight: FontWeight.bold,
                           color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
