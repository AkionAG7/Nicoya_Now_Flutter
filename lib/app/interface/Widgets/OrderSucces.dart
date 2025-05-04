import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';

class OrderSucces extends StatefulWidget {
  const OrderSucces({Key? key}) : super(key: key);

  @override
  _OrderSuccesState createState() => _OrderSuccesState();
}

class _OrderSuccesState extends State<OrderSucces> {
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
                    'lib/app/interface/public/WallpaperOrderSucces.png',
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

            SizedBox(
              height: 80,
              width: 300,
              child: ElevatedButton(
                onPressed: () => print('implentar navigate'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Color(0xffd72a23),
                ),
                child: Text(
                  'Ordenar de nuevo',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
