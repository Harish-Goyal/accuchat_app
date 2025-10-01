import 'dart:convert';


import 'package:AccuChat/Services/subscription/sub_model.dart';
import 'package:http/http.dart' as http;

enum BillingCycle { monthly, quarterly, yearly }

extension BillingCycleX on BillingCycle {
  String get api => toString().split('.').last; // monthly | quarterly | yearly
}

// ----------------------------- billing_service.dart -----------------------------


class BillingService {
  final String baseUrl; // e.g., https://api.accuchat.app
  final Future<String?> Function() authTokenProvider; // supply JWT

  BillingService({required this.baseUrl, required this.authTokenProvider});

  Future<Map<String, String>> _headers() async => {
    'Content-Type': 'application/json',
    if ((await authTokenProvider()) != null) 'Authorization': 'Bearer ${await authTokenProvider()}',
  };

  Future<EntitlementSummary> getSummary() async {
    final r = await http.get(Uri.parse('$baseUrl/billing/summary'), headers: await _headers());
    if (r.statusCode != 200) {
      throw Exception('Failed to fetch billing summary');
    }
    return EntitlementSummary.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> checkout({
    required String kind, // 'company_pack' | 'user_pack'
    String? companyId,
    required int quantity,
    required BillingCycle cycle,
    required bool autoRenew,
  }) async {
    final body = jsonEncode({
      'kind': kind,
      if (companyId != null) 'companyId': companyId,
      'quantity': quantity,
      'billing_cycle': cycle.api,
      'auto_renew': autoRenew,
    });
    final r = await http.post(Uri.parse('$baseUrl/billing/checkout'), headers: await _headers(), body: body);
    if (r.statusCode != 200) {
      throw Exception('Checkout failed: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>; // { processor, order_payload }
  }

  Future<http.Response> ensureSeats({required String companyId, required int seatsNeeded}) async {
    final body = jsonEncode({'seatsNeeded': seatsNeeded});
    final r = await http.post(
      Uri.parse('$baseUrl/companies/$companyId/ensure-seats'),
      headers: await _headers(),
      body: body,
    );
    return r; // 200 OK if enough seats; 402 with {code:'NEED_USER_PACK', data:{avail,seatsNeeded}}
  }
}
