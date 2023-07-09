import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/services/payments/yookassa_payment_request.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_message_box.dart';
import 'package:yookassa_payments_flutter/yookassa_payments_flutter.dart';
import '../../user_data/user.dart';
import 'package:uuid/uuid.dart';

class YookassaPayments {
  YookassaPayments() {
    _idempotenceKey = Uuid().v4();
    _idempotenceKeyForCheckStatus = Uuid().v4();
  }

  late  String _idempotenceKey;
  late  String _idempotenceKeyForCheckStatus;

  Future pay(BuildContext context,
      {String? title,
      String? subtitle,
      double? amountInRub,
      Function? onComplete,
      required bool testMode}) async {
    final _paymentMethodTypes = PaymentMethodTypes([PaymentMethod.bankCard]);
    final _clientApplicationKey =
        "live_MjI0MzQ0QbhxKs1fv9QJbgcRxPRkeZ4Rs3FWJmqo-TM";
    final _amount = Amount(value: amountInRub ?? 990, currency: Currency.rub);
    final _shopId = "224344";
    final _clientId = 'td00l1l9g7g7i80jbu9l62g5ia4b82lv';
    final _description =
        subtitle ?? "Ограниченный доступ к рекомендациям, статистике и аудио";
    final _tokenizationModuleInputData = TokenizationModuleInputData(
      clientApplicationKey: _clientApplicationKey,
      title: title ?? "Rigel PSY",
      subtitle: _description,
      amount: _amount,
      shopId: _shopId,
      testModeSettings: testMode
          ? TestModeSettings(
              false, 1, Amount(value: 990, currency: Currency.rub), false)
          : null,
      moneyAuthClientId: _clientId,
      tokenizationSettings: TokenizationSettings(_paymentMethodTypes),
      savePaymentMethod: SavePaymentMethod.off,
    );
    final TokenizationResult result =
        await YookassaPaymentsFlutter.tokenization(
            _tokenizationModuleInputData);

    _getAnswer(context,
        result: result,
        onSuccess: (result) async {
          final _token = result.token;
          final _paymentMethodType = result.paymentMethodType;
          final yookassaPaymentRequest = YookassaPaymentRequest(_amount);
          final paymentRequest =
              await yookassaPaymentRequest.makePaymentRequest(
                  token: _token,
                  paymentMethod: _paymentMethodType!,
                  description: _description,
                  idempotenceKey: _idempotenceKey);

          final _confirmationUrl = paymentRequest['confirmation_url'];
          final _paymentId = paymentRequest['payment_id'];
          if (_confirmationUrl.isEmpty || _paymentId.isEmpty) {
            _onPaymentError(context);
          } else {
            YookassaPaymentsFlutter.confirmation(
                    _confirmationUrl, _paymentMethodType)
                .then((value) async {
              print('payment succes');
              if (await yookassaPaymentRequest.checkPaymentStatus(
                  _paymentId, _idempotenceKeyForCheckStatus)) {
                _onPaymentSucceed(onComplete!());
              } else {
                _onPaymentCancel(context);
              }
            });
          }
        },
        onCancel: () => _onPaymentCancel(context),
        onError: (result) => _onPaymentError(context));
  }

  bool _getAnswer(BuildContext context,
      {required TokenizationResult result,
      required Function(SuccessTokenizationResult) onSuccess,
      required Function onCancel,
      required Function(ErrorTokenizationResult) onError}) {
    if (result is SuccessTokenizationResult) {
      onSuccess(result);
      return true;
    }
    if (result is CanceledTokenizationResult) {
      onCancel();
    } else {
      onError(result as ErrorTokenizationResult);
      print((result).error);
    }
    return false;
  }

  _onPaymentSucceed(Function onComplete) {
    onComplete!();
  }

  _onPaymentCancel(BuildContext context) {
    _idempotenceKey = Uuid().v4();
    _idempotenceKeyForCheckStatus = Uuid().v4();
    showDialog(
        context: context,
        builder: (c) => CustomMessageBox(
            title: 'Подписка', content: 'Вы отменили покупку'));
  }

  _onPaymentError(BuildContext context) {
    _idempotenceKey = Uuid().v4();
    _idempotenceKeyForCheckStatus = Uuid().v4();
    showDialog(
        context: context,
        builder: (c) =>
            CustomMessageBox(title: 'Подписка', content: 'Произошла ошибка, повторите попытку или попробуйте позднее'));
  }
}
