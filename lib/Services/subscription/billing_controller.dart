import 'package:AccuChat/Services/subscription/sub_model.dart';
import 'package:get/get.dart';

import 'billing_service.dart';

class BillingController extends GetxController {
  final BillingService service;
  BillingController(this.service);

  EntitlementSummary? summary;
  bool loading = false;

  Future<void> refreshSummary() async {
    loading = true;
    update();
    try {
      summary = await service.getSummary();
    } finally {
      loading = false;
      update();
    }
  }

  bool get isInGrace => summary?.subscriptionStatus == 'grace';
  bool get isExpiredOrPastDue => ['expired', 'past_due'].contains(summary?.subscriptionStatus);






}