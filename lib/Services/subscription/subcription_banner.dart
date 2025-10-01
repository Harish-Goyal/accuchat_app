import 'package:AccuChat/Services/subscription/billing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SubscriptionBanner extends StatelessWidget {
  final BillingController ctrl;
  const SubscriptionBanner({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillingController>(
      builder: (_) {
        final s = ctrl.summary;
        if (s == null) return const SizedBox.shrink();

        if (ctrl.isInGrace) {
          return Container(
            padding: const EdgeInsets.all(12),
            color: Colors.orangeAccent.withOpacity(0.2),
            child: Row(children: [
              const Icon(Icons.error_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your plan expired on ${fmtDate(s.currentPeriodEnd)}. You are in grace until ${fmtDate(s.graceUntil)}. Please renew to avoid disabling paid seats/companies.',
                ),
              ),
              TextButton(onPressed: () => openBilling(), child: const Text('Manage')),
            ]),
          );
        }

        if (ctrl.isExpiredOrPastDue) {
          return Container(
            padding: const EdgeInsets.all(12),
            color: Colors.redAccent.withOpacity(0.15),
            child: Row(children: [
              const Icon(Icons.lock_outline),
              const SizedBox(width: 8),
              const Expanded(child: Text('Paid features are disabled. Renew to re-enable additional companies and seats.')),
              TextButton(onPressed: () => openBilling(), child: const Text('Renew')),
            ]),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String fmtDate(DateTime? d) => d == null ? '-' : '${d.day}/${d.month}/${d.year}';


  void openBilling() {
    // Navigate to your Billing/Plans screen
    Get.toNamed('/billing');
  }
}