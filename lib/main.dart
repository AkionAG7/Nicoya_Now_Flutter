// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';     
import 'package:supabase_flutter/supabase_flutter.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar las variables definidas en .env
  await dotenv.load(fileName: '.env');

  // 2. Inicializar Supabase con esas variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!, 
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Arrancar la app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Nicoya Now',
      home: Scaffold(
        body: Center(
          child: Text('¡Supabase conectado!'),
        ),
      ),
    );
  }
}
