import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../Constants/colors.dart';
import '../../../../Services/subscription/billing_service.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/text_style.dart';

class BuyCompanyPackDialog extends StatefulWidget {
  const BuyCompanyPackDialog();

  @override
  State<BuyCompanyPackDialog> createState() => _BuyCompanyPackDialogState();
}

class _BuyCompanyPackDialogState extends State<BuyCompanyPackDialog> {
  BillingCycle _cycle = BillingCycle.monthly;
  bool _auto = true;

  // Company charge is 0 here because we're only upgrading users on an existing company.
  final Map<BillingCycle, int> companyPackPrice = {
    BillingCycle.monthly: 0,
    BillingCycle.quarterly: 0,
    BillingCycle.yearly: 0,
  };

  // Price per 5-seat user pack (INR) per cycle
  final Map<BillingCycle, int> userPack5Price = {
    BillingCycle.monthly: 199,
    BillingCycle.quarterly: 549,
    BillingCycle.yearly: 1899,
  };

  /// Seats to ADD (in steps of 5). Start at 5 to make at least one pack by default.
  int _seatsToAdd = 5;

  void _inc() => setState(() => _seatsToAdd = (_seatsToAdd + 5).clamp(5, 200));
  void _dec() => setState(() => _seatsToAdd = (_seatsToAdd - 5).clamp(5, 200));

  /// Number of 5-seat packs being purchased
  int get _packs => (_seatsToAdd / 5).ceil();

  /// Pricing math
  int get _amountCompany => companyPackPrice[_cycle] ?? 0; // will stay 0
  int get _amountUserPacks => (userPack5Price[_cycle] ?? 0) * _packs;
  int get _subTotal => _amountCompany + _amountUserPacks;

  /// Taxes
  double get _gst5 => _subTotal * 0.05; // 5% GST
  double get _otherTax0 => 0.0;         // Other tax 0%

  /// Grand total (rounded to whole INR)
  int get _grandTotal => (_subTotal + _gst5 + _otherTax0).round();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        "Upgrade Company's Users",
        style: BalooStyles.balooboldTitleTextStyle(size: 15),
      ),
      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Helper text
          Text(
            'Add users in packs of 5. (Per company 20 users are free)',
            style: BalooStyles.baloonormalTextStyle(),
          ),
          vGap(15),

          // Seats selector
          Row(
            children: [
              Flexible(
                child: Text('Users to add', style: BalooStyles.baloosemiBoldTextStyle()),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _dec,
                      icon: Icon(Icons.remove_circle_outline, color: appColorYellow),
                    ),
                    Text('$_seatsToAdd', style: BalooStyles.baloomediumTextStyle()),
                    IconButton(
                      onPressed: _inc,
                      icon: Icon(Icons.add_circle_outline, color: appColorYellow),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '($_packs × 5-user pack${_packs > 1 ? 's' : ''})',
              style: BalooStyles.baloonormalTextStyle(),
            ),
          ),

          divider(),

          // Cycle + auto renew
          DropdownButton<BillingCycle>(
            value: _cycle,
            dropdownColor: Colors.white,
            onChanged: (v) => setState(() => _cycle = v!),
            items: BillingCycle.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.api)))
                .toList(),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CupertinoCheckbox(
                value: _auto,
                onChanged: (v) => setState(() => _auto = v ?? true),
                activeColor: appColorGreen,
              ),
              Text('Auto-renew', style: BalooStyles.baloonormalTextStyle()),
            ],
          ),

          vGap(8),

          // Amount preview
          Text(
            'Amount (per ${_cycle.api})',
            style: BalooStyles.baloomediumTextStyle(),
          ),
          vGap(8),

          // Company (0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Company Pack (existing company)', style: BalooStyles.baloonormalTextStyle()),
              Text('₹$_amountCompany', style: BalooStyles.baloomediumTextStyle()),
            ],
          ),
          vGap(4),

          // User packs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Packs ($_packs × 5 seats)', style: BalooStyles.baloonormalTextStyle()),
              Text('₹$_amountUserPacks', style: BalooStyles.baloomediumTextStyle()),
            ],
          ),

          vGap(8),
          divider(),
          vGap(8),

          // Taxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GST @ 5%', style: BalooStyles.baloonormalTextStyle()),
              Text('₹${_gst5.toStringAsFixed(0)}', style: BalooStyles.baloomediumTextStyle()),
            ],
          ),
          vGap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Other Tax @ 0%', style: BalooStyles.baloonormalTextStyle()),
              Text('₹${_otherTax0.toStringAsFixed(0)}', style: BalooStyles.baloomediumTextStyle()),
            ],
          ),

          vGap(12),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: BalooStyles.baloosemiBoldTextStyle()),
              Text('₹$_grandTotal', style: BalooStyles.baloosemiBoldTextStyle()),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            BuyPackResult(
              _cycle,
              _auto,
              totalSeats: _seatsToAdd,  // seats being added now
              extraPacks: _packs,       // number of 5-seat packs
              subTotal: _subTotal,
              gst5: _gst5.round(),
              otherTax0: _otherTax0.round(),
              grandTotal: _grandTotal,
            ),
          ),
          child: const Text('Proceed to Pay'),
        ),
      ],
    );
  }
}

class BuyPackResult {
  final BillingCycle cycle;
  final bool autoRenew;

  /// Seats being added now (not total company seats)
  final int totalSeats;

  /// Number of 5-seat packs being purchased
  final int extraPacks;

  /// Billing breakdown
  final int subTotal;
  final int gst5;
  final int otherTax0;
  final int grandTotal;

  BuyPackResult(
      this.cycle,
      this.autoRenew, {
        required this.totalSeats,
        required this.extraPacks,
        required this.subTotal,
        required this.gst5,
        required this.otherTax0,
        required this.grandTotal,
      });
}
