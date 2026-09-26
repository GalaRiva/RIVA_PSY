import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/services/apple_billing_service.dart';
import '../core/services/google_play_billing_service.dart';

// Guideline 3.1.2(a) / ADPLA Schedule 2 §3.8(b): the purchase control itself
// must show the subscription title, length and price. The old buttons said
// only "Год" / "Месяц". This resolves the real store price (so it's always
// localized and matches what StoreKit / Play will charge) and falls back to
// the old short label until it loads or if the store is unavailable.
class PlanPriceBuilder extends StatefulWidget {
  final String productId;
  final bool yearly;
  final String fallbackText;
  final Widget Function(String text) builder;

  const PlanPriceBuilder({
    Key? key,
    required this.productId,
    required this.yearly,
    required this.fallbackText,
    required this.builder,
  }) : super(key: key);

  @override
  State<PlanPriceBuilder> createState() => _PlanPriceBuilderState();
}

class _PlanPriceBuilderState extends State<PlanPriceBuilder> {
  static final Map<String, String> _cache = {};
  String? _price;

  @override
  void initState() {
    super.initState();
    _price = _cache[widget.productId];
    if (_price == null) _load();
  }

  Future<void> _load() async {
    try {
      final p = Platform.isIOS
          ? await AppleBillingService.queryProduct(widget.productId)
          : await GooglePlayBillingService.queryProduct(widget.productId);
      if (p == null) return;
      _cache[widget.productId] = p.price;
      if (mounted) setState(() => _price = p.price);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final price = _price;
    final text = price == null
        ? widget.fallbackText
        : (widget.yearly ? 'plan_yearly_with_price' : 'plan_monthly_with_price')
            .tr(namedArgs: {'price': price}).toUpperCase();
    return widget.builder(text);
  }
}
