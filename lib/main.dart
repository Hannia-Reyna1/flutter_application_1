import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/auth_screen.dart'; // ✅ Importación de pantalla de autenticación
import 'cart_provider.dart'; // ✅ Importación corregida
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Stripe.publishableKey =
      'pk_test_51RTDEFGfaBo1dFtivNS32dmyb0NcyL9uX9lxVJxxGxBwTT2im45e8IztAfEV9rSznMT9ralX2Q8rDBcvzuQzSIsc00vqjSkk4S'; // Tu clave pública de Stripe

  final cartProvider = CartProvider();
  await cartProvider.cargarCarrito(); // ✅ Recupera los productos guardados

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => cartProvider)],
      child: const TermoApp(),
    ),
  );
}

class TermoApp extends StatelessWidget {
  const TermoApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔹 Construyendo la aplicación...');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ), // ✅ Estado global del carrito
      ],
      child: MaterialApp(
        title: 'Venta de Termos',
        debugShowCheckedModeBanner: false, // ✅ Oculta el banner de debug
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true, // ✅ Habilitar Material 3
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/login':
              (context) => const AuthScreen(), // ✅ Agregamos la ruta de login
        },
        builder: (context, child) {
          return SafeArea(
            // ✅ Evita interferencias con barras de estado y gestos
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  1.1,
                ), // ✅ Escalado para mejorar legibilidad
              ),
              child: child ?? Container(),
            ),
          );
        },
      ),
    );
  }
}
