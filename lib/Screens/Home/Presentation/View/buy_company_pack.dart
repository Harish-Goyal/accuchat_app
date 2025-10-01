import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../Constants/colors.dart';
import '../../../../Services/subscription/billing_service.dart';
import '../../../../utils/helper_widget.dart';
import '../../../../utils/text_style.dart';

class BuyMultipleCompaniesDialog extends StatefulWidget {
  const BuyMultipleCompaniesDialog();

  @override
  State<BuyMultipleCompaniesDialog> createState() => _BuyMultipleCompaniesDialogState();
}

class _BuyMultipleCompaniesDialogState extends State<BuyMultipleCompaniesDialog> {
  BillingCycle _cycle = BillingCycle.monthly;
  bool _auto = true;

  /// Pricing (INR) per company per cycle
  final Map<BillingCycle, int> companyPackPrice = {
    BillingCycle.monthly: 499,
    BillingCycle.quarterly: 1299,
    BillingCycle.yearly: 4499,
  };

  /// Quantity of companies to buy
  int _companyQty = 1;
  void _incQty() => setState(() => _companyQty = (_companyQty + 1).clamp(1, 99));
  void _decQty() => setState(() => _companyQty = (_companyQty - 1).clamp(1, 99));

  int get _unitPrice => companyPackPrice[_cycle] ?? 0;
  int get _subTotal => _unitPrice * _companyQty;

  /// Taxes
  double get _tax5 => (_subTotal * 0.05);
  double get _otherTax0 => 0.0;

  /// Grand total (rounded to whole INR)
  int get _grandTotal => (_subTotal + _tax5 + _otherTax0).round();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text('Buy Companies', style: BalooStyles.balooboldTitleTextStyle(size: 15)),
      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      insetPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      content: /*Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Purchase additional companies for your account.',
            style: BalooStyles.baloomediumTextStyle(size: 15),
          ),
          vGap(6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline_rounded, size: 16),
              hGap(6),
              Expanded(
                child: Text(
                  'Per company 20 users free.',
                  style: BalooStyles.baloonormalTextStyle(),
                ),
              ),
            ],
          ),
          vGap(12),
          // Quantity selector
          Row(
            children: [
              Flexible(child: Text('Companies', style: BalooStyles.baloosemiBoldTextStyle())),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: _decQty,
                      icon: Icon(Icons.remove_circle_outline, color: appColorYellow),
                      tooltip: 'Decrease',
                    ),
                    Text('$_companyQty', style: BalooStyles.baloomediumTextStyle()),
                    IconButton(
                      onPressed: _incQty,
                      icon: Icon(Icons.add_circle_outline, color: appColorYellow),
                      tooltip: 'Increase',
                    ),
                  ],
                ),
              ),
            ],
          ),
          divider(),
          // Billing cycle + auto renew
          DropdownButton<BillingCycle>(
            value: _cycle,
            dropdownColor: Colors.white,
            onChanged: (v) => setState(() => _cycle = v!),
            items: BillingCycle.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.api)))
                .toList(),
          ),
          Row(
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
          Text('Amount (per ${_cycle.api})', style: BalooStyles.baloomediumTextStyle()),
          vGap(8),
          // Line items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Company Pack ($_companyQty × ₹$_unitPrice)', style: BalooStyles.baloonormalTextStyle()),
              Text('₹$_subTotal', style: BalooStyles.baloomediumTextStyle()),
            ],
          ),
          vGap(4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax @ 5%', style: BalooStyles.baloonormalTextStyle()),
              Text('₹${_tax5.toStringAsFixed(0)}', style: BalooStyles.baloomediumTextStyle()),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: BalooStyles.baloosemiBoldTextStyle()),
              Text('₹$_grandTotal', style: BalooStyles.baloosemiBoldTextStyle()),
            ],
          ),
        ],
      )*/Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Coming Soon!",style: BalooStyles.balooboldTitleTextStyle(size: 20),textAlign: TextAlign.center,),
          vGap(15),
          Text("Our team is currently working on this feature, and it will be available soon.",style: BalooStyles.baloonormalTextStyle(),textAlign: TextAlign.center,),
          vGap(15),
          Text("Thanks so much for your patience!",style: BalooStyles.baloomediumTextStyle(),textAlign: TextAlign.center,),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ok')),
       /* ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            BuyCompaniesResult(
              _cycle,
              _auto,
              companyQty: _companyQty,
              unitPrice: _unitPrice,
              subTotal: _subTotal,
              tax5: _tax5.round(),
              otherTax0: _otherTax0.round(),
              grandTotal: _grandTotal,
            ),
          ),
          child: const Text('Proceed to Pay'),
        ),*/
      ],
    );
  }
}

class BuyCompaniesResult {
  final BillingCycle cycle;
  final bool autoRenew;
  final int companyQty;

  /// Echoed back for convenience
  final int unitPrice;
  final int subTotal;
  final int tax5;
  final int otherTax0;
  final int grandTotal;

  BuyCompaniesResult(
      this.cycle,
      this.autoRenew, {
        required this.companyQty,
        required this.unitPrice,
        required this.subTotal,
        required this.tax5,
        required this.otherTax0,
        required this.grandTotal,
      });
}
