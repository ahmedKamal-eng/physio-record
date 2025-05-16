
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constant.dart';


class PaymobService {
  final String apiKey = Constant.api_key;
  final String integrationId = '3339902';

  // Step 1: Get Authentication Token
  Future<String> getAuthToken() async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/auth/tokens'),
      body: jsonEncode({'api_key': apiKey}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception('Failed to get auth token');
    }
  }

  // Step 2: Create an Order
  Future<String> createOrder(String authToken, String subscriptionType,int monthly,int quarterly,int yearly) async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/ecommerce/orders'),
      body: jsonEncode({
        'auth_token': authToken,
        'delivery_needed': false,
        'amount_cents': subscriptionType == 'monthly'
            ? monthly // Monthly cost in cents (EGP 100.00)
            : subscriptionType == 'quarterly'
            ? quarterly // Quarterly cost in cents (EGP 250.00)
            : yearly, // Yearly cost in cents (EGP 900.00)
        'currency': 'EGP',
        'items': []
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)['id'].toString();
    } else {
      throw Exception('Failed to create order');
    }
  }

  // Step 3: Generate Payment Key
  Future<String> generatePaymentKey(
      String authToken, String orderId, String amount) async {
    final response = await http.post(
      Uri.parse('https://accept.paymob.com/api/acceptance/payment_keys'),
      body: jsonEncode({
        'auth_token': authToken,
        'amount_cents': amount,
        'expiration': 3600,
        'order_id': orderId,
        'billing_data': {
          'apartment': 'NA',
          'email': 'user@example.com',
          'floor': 'NA',
          'first_name': 'User',
          'last_name': 'Example',
          'street': 'NA',
          'building': 'NA',
          'phone_number': '+201234567890',
          'shipping_method': 'NA',
          'postal_code': 'NA',
          'city': 'Cairo',
          'country': 'EGY',
          'state': 'Cairo',
        },
        'currency': 'EGP',
        'integration_id': integrationId,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      print("========================="+"success"+"_____________________________");
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception('Failed to generate payment key');
    }
  }
}
