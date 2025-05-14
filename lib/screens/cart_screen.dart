import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _procesandoPago = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de Compras')),
      body: FutureBuilder(
        future: context.read<CartProvider>().cargarCarrito(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return Consumer<CartProvider>(
            builder: (context, cartProvider, _) {
              return cartProvider.carrito.isEmpty
                  ? const Center(child: Text('Tu carrito está vacío'))
                  : ListView.builder(
                      itemCount: cartProvider.carrito.length,
                      itemBuilder: (_, index) {
                        final producto = cartProvider.carrito[index];
                        return Card(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(producto['nombre']),
                            subtitle: Text("Cantidad: ${producto['cantidad'] ?? 1}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => cartProvider.eliminarProducto(index),
                            ),
                          ),
                        );
                      },
                    );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return cartProvider.carrito.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total: \$${cartProvider.calcularTotal()} MXN', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: cartProvider.vaciarCarrito,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Vaciar carrito'),
                          ),
                          ElevatedButton(
                            onPressed: _procesandoPago ? null : () => _procesarPago(context, FirebaseAuth.instance.currentUser, cartProvider),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: _procesandoPago ? const CircularProgressIndicator() : const Text('Pagar con Mercado Pago'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : const Center(child: Text('Tu carrito está vacío'));
        },
      ),
    );
  }

  void _procesarPago(BuildContext context, User? user, CartProvider cartProvider) async {
    setState(() {
      _procesandoPago = true;
    });

    try {
      if (user == null) {
        if (context.mounted) {
          Navigator.pushNamed(context, '/login');
        }
        return;
      }

      if (!user.emailVerified) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📩 Verifica tu correo antes de comprar')));
        }
        user.sendEmailVerification();
        return;
      }

      if (cartProvider.carrito.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🛒 No puedes pagar con el carrito vacío')));
        }
        return;
      }

      bool pagoExitoso = await _realizarPago(cartProvider.calcularTotal());

      if (context.mounted) {
        if (pagoExitoso) {
          Navigator.pushNamed(context, '/success');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Hubo un error en el pago')));
        }
      }
    } catch (e) {
      debugPrint("🔥 Error en _procesarPago(): $e");
    } finally {
      setState(() {
        _procesandoPago = false;
      });
    }
  }

  Future<bool> _realizarPago(double total) async {
    try {
      final Uri url = Uri.parse("https://api.mercadopago.com/sandbox/v1/payments"); // ✅ Cambio a modo Sandbox

      final paymentData = {
        "transaction_amount": total,
        "token": "TEST-1204931644700320-050720-4357c3f4d56a7584e7b68dc4b639a351-417416466",
        "description": "Compra en Tienda de Termos",
        "payment_method_id": "visa",
        "payer": {"email": "cliente@email.com"}
      };

      debugPrint("🚀 Enviando datos a Mercado Pago: ${jsonEncode(paymentData)}");

      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer TU_ACCESS_TOKEN",
          "Content-Type": "application/json"
        },
        body: jsonEncode(paymentData),
      );

      debugPrint("🔎 Respuesta de Mercado Pago: ${response.body}");

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("❌ Error en el pago: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("🔥 Error en _realizarPago(): $e");
      return false;
    }
  }
}