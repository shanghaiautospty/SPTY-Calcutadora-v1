import 'package:flutter/material.dart';

void main() {
  runApp(const SPTYCalculadoraApp());
}

class SPTYCalculadoraApp extends StatelessWidget {
  const SPTYCalculadoraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPTY Calculadora',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CalculadoraHomePage(),
    );
  }
}

class CalculadoraHomePage extends StatefulWidget {
  const CalculadoraHomePage({Key? key}) : super(key: key);

  @override
  State<CalculadoraHomePage> createState() => _CalculadoraHomePageState();
}

class _CalculadoraHomePageState extends State<CalculadoraHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPTY Calculadora'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Bienvenido a SPTY Calculadora'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navegar a comparación EV vs Gasolina
              },
              child: const Text('Comparar EV vs Gasolina'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // TODO: Navegar a comparación EV vs Diésel
              },
              child: const Text('Comparar EV vs Diésel'),
            ),
          ],
        ),
      ),
    );
  }
}