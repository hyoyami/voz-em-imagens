import 'package:flutter/material.dart';

import 'services/voz_service.dart';
import 'views/inicio_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VozService.instancia.iniciar();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voz em Imagens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4DB6AC),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
      ),
      home: const InicioView(),
    );
  }
}
