import 'package:flutter/material.dart';

class TestImagesPage extends StatelessWidget {
  const TestImagesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Images'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImageTest('lib/app/interface/Public/LogoApp.png', 'LogoApp.png'),
            _buildImageTest('lib/app/interface/Public/LoginImage.png', 'LoginImage.png'),
            _buildImageTest('lib/app/interface/Public/SplashFT1.png', 'SplashFT1.png'),
            _buildImageTest('lib/app/interface/Public/SplashFT2.png', 'SplashFT2.png'),
            _buildImageTest('lib/app/interface/Public/SplashFT3.png', 'SplashFT3.png'),
            _buildImageTest('lib/app/interface/Public/WallpaperOrderSucces.png', 'WallpaperOrderSucces.png'),
            _buildImageTest('lib/app/interface/Public/Comercio.png', 'Comercio.png'),
            _buildImageTest('lib/app/interface/Public/Repartidor.png', 'Repartidor.png'),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTest(String assetPath, String name) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset: $name',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Image.asset(
              assetPath,
              height: 100,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: Colors.red.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: Text(
                    'Error loading: $error',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
