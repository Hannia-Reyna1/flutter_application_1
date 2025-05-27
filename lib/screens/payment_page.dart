import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  PaymentPageState createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment() async {
    try {
      // Llama a tu backend para obtener clientSecret
      final response = await http.post(
        Uri.parse('https://tu-backend.com/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'amount': 5000, 'currency': 'usd'}), // 50 USD
      );

      paymentIntentData = json.decode(response.body);

      // Inicializa el método de pago
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['clientSecret'],
          merchantDisplayName: 'Mi Tienda Flutter',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Pago exitoso")));
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pagar con Stripe')),
      body: Center(
        child: ElevatedButton(
          onPressed: makePayment,
          child: Text('Pagar \$50'),
        ),
      ),
    );
  }
}
