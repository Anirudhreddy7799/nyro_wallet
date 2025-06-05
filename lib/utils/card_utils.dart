import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

/// Returns a user-friendly string (e.g., "Visa", "Mastercard") based on CreditCardType.
String cardTypeToFriendlyName(CreditCardType type) {
  switch (type) {
    case CreditCardType.visa:
      return 'Visa';
    case CreditCardType.mastercard:
      return 'Mastercard';
    case CreditCardType.amex:
      return 'American Express';
    case CreditCardType.discover:
      return 'Discover';
    case CreditCardType.jcb:
      return 'JCB';
    case CreditCardType.maestro:
      return 'Maestro';
    case CreditCardType.mir:
      return 'MIR';
    case CreditCardType.elo:
      return 'Elo';
    case CreditCardType.hipercard:
      return 'Hipercard';
    default:
      return 'Unknown';
  }
}

/// Returns a small icon widget (or placeholder) for each card type.
Widget cardTypeIcon(CreditCardType type, {double size = 24}) {
  switch (type) {
    case CreditCardType.visa:
      return Image.asset('assets/cards/visa.png', width: size, height: size);
    case CreditCardType.mastercard:
      return Image.asset(
        'assets/cards/mastercard.png',
        width: size,
        height: size,
      );
    case CreditCardType.amex:
      return Image.asset('assets/cards/amex.png', width: size, height: size);
    case CreditCardType.discover:
      return Image.asset(
        'assets/cards/discover.png',
        width: size,
        height: size,
      );
    case CreditCardType.jcb:
      return Image.asset('assets/cards/jcb.png', width: size, height: size);
    case CreditCardType.maestro:
      return Image.asset('assets/cards/maestro.png', width: size, height: size);
    case CreditCardType.mir:
      return Image.asset('assets/cards/mir.png', width: size, height: size);
    case CreditCardType.elo:
      return Image.asset('assets/cards/elo.png', width: size, height: size);
    case CreditCardType.hipercard:
      return Image.asset(
        'assets/cards/hipercard.png',
        width: size,
        height: size,
      );
    default:
      return Icon(Icons.credit_card, size: size, color: Colors.grey.shade400);
  }
}

String detectCardAsset(String cardNumber) {
  final digitsOnly = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.isEmpty) {
    return 'assets/cards/placeholder_card.png';
  }

  if (RegExp(r'^(34|37)[0-9]{13}').hasMatch(digitsOnly)) {
    return 'assets/cards/amex.png';
  } else if (RegExp(r'^4[0-9]{12}(?:[0-9]{3})?$').hasMatch(digitsOnly)) {
    return 'assets/cards/visa.png';
  } else if (RegExp(r'^(5[1-5][0-9]{14})$').hasMatch(digitsOnly)) {
    return 'assets/cards/mastercard.png';
  }

  return 'assets/cards/placeholder_card.png';
}
