import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';

class MercadoPagoService {
  final String accessToken = "TU_ACCESS_TOKEN"; // ✅ Reemplaza con tu token real

  Future<String?> crearPago(double amount, String email) async {
    if (amount <= 0 || email.isEmpty) {
      log("❌ Error: Monto o correo inválido.");
      return null;
    }

    final url = Uri.parse("https://api.mercadopago.com/v1/payments");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken", // ✅ Autenticación con MercadoPago
        },
        body: jsonEncode({
          "transaction_amount": amount,
          "payer": {"email": email},
          "payment_method_id": "visa", // ✅ Cambia según el método de pago
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["status"]; // ✅ Retorna el estado del pago
      } else {
        log("❌ Error en el pago (${response.statusCode}): ${response.body}");
        return null;
      }
    } catch (e) {
      log("❌ Excepción al procesar el pago: $e");
      return null;
    }
  }
}