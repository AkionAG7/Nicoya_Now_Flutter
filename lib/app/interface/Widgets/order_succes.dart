import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class OrderSucces extends StatefulWidget {
  const OrderSucces({super.key});

  @override
  OrderSuccesState createState() => OrderSuccesState();
}

class OrderSuccesState extends State<OrderSucces> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: screenHeight * 0.5,
                  width: double.infinity,
                  child: Image.asset(
                    'lib/app/interface/Public/WallpaperOrderSucces.png',
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.27,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 200,
                      color: Color(0xff32cd70),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Text(
              'Orden completada',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xff000000),
              ),
            ),

            SizedBox(height: 150),

            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: SizedBox(
                height: 80,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xffd72a23),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, Routes.clientNav);
                  },
                  child: Text(
                    'Ver mi pedido',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
