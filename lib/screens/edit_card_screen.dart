import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/card_utils.dart';

class EditCardScreen extends StatefulWidget {
  static const routeName = '/edit_card';

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberCtrl;
  late TextEditingController _expiryCtrl;
  late TextEditingController _cvvCtrl;
  late TextEditingController _nicknameCtrl;
  late TextEditingController _cardHolderNameController;
  String _cardType = 'Visa';
  String? _cardId;
  bool _loading = false;
  CreditCardType? _detectedCardType;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController();
    _expiryCtrl = TextEditingController();
    _cvvCtrl = TextEditingController();
    _nicknameCtrl = TextEditingController();
    _cardHolderNameController = TextEditingController();
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nicknameCtrl.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\s+'), '');
    if (digitsOnly.length >= 6) {
      final detectedType = detectCCType(digitsOnly);
      setState(() {
        _detectedCardType = detectedType;
      });
    } else {
      setState(() {
        _detectedCardType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final cardData = args['cardData'] as Map<String, dynamic>;
    _cardId = args['cardId'] as String;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_numberCtrl.text.isEmpty && cardData.isNotEmpty) {
        _prefillFields(cardData);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Card')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _numberCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                      ),
                      onChanged: _onCardNumberChanged,
                      validator: _validateCardNumber,
                    ),
                    if (_detectedCardType != null) ...[
                      Row(
                        children: [
                          cardTypeIcon(_detectedCardType!),
                          const SizedBox(width: 8),
                          Text(cardTypeToFriendlyName(_detectedCardType!)),
                        ],
                      ),
                    ],
                    TextFormField(
                      controller: _expiryCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date (MM/YY)',
                      ),
                      validator: _validateExpiry,
                    ),
                    TextFormField(
                      controller: _cvvCtrl,
                      decoration: const InputDecoration(labelText: 'CVV'),
                    ),
                    TextFormField(
                      controller: _nicknameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nickname (Optional)',
                      ),
                    ),
                    TextFormField(
                      controller: _cardHolderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Cardholder Name',
                        hintText: 'Alice Example',
                        filled: true,
                        fillColor: Colors.white24,
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter cardholder name';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _cardType,
                      items: const [
                        DropdownMenuItem(value: 'Visa', child: Text('Visa')),
                        DropdownMenuItem(
                          value: 'Mastercard',
                          child: Text('Mastercard'),
                        ),
                        DropdownMenuItem(value: 'Amex', child: Text('Amex')),
                      ],
                      onChanged: (val) => setState(() => _cardType = val!),
                    ),
                    ElevatedButton(
                      onPressed: _onSavePressed,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _prefillFields(Map<String, dynamic> cardData) {
    _numberCtrl.text = cardData['cardNumber'] ?? '';
    _expiryCtrl.text =
        '${cardData['expiryMonth']?.toString().padLeft(2, '0')}/${cardData['expiryYear']?.toString().substring(2)}';
    _cvvCtrl.text = cardData['cvv'] ?? '';
    _nicknameCtrl.text = cardData['nickname'] ?? '';
    _cardHolderNameController.text = cardData['cardHolderName'] ?? '';
    _cardType = cardData['cardType'] ?? 'Visa';
  }

  Future<void> _onSavePressed() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      final updatedData = {
        'cardNumber': _numberCtrl.text,
        'expiryMonth': int.parse(_expiryCtrl.text.split('/')[0]),
        'expiryYear': int.parse('20${_expiryCtrl.text.split('/')[1]}'),
        'cvv': _cvvCtrl.text,
        'nickname': _nicknameCtrl.text,
        'cardHolderName': _cardHolderNameController.text,
        'cardType': _cardType,
      };

      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('cards')
            .doc(_cardId)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card updated successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update card: $e')));
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your card number';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length != 15 && digitsOnly.length != 16) {
      return 'Card number must be 15 or 16 digits';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter expiry date';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    int month, year;
    if (digitsOnly.length == 4) {
      month = int.tryParse(digitsOnly.substring(0, 2)) ?? 0;
      year = int.tryParse(digitsOnly.substring(2, 4)) ?? 0;
      year += 2000;
    } else if (digitsOnly.length == 6) {
      month = int.tryParse(digitsOnly.substring(0, 2)) ?? 0;
      year = int.tryParse(digitsOnly.substring(2, 6)) ?? 0;
    } else {
      return 'Enter a valid expiry date (MM/YY or MM/YYYY)';
    }
    if (month < 1 || month > 12) {
      return 'Invalid month (01–12)';
    }
    final expiryDate = DateTime(year, month + 1, 0);
    final now = DateTime.now();
    if (expiryDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'Card has expired';
    }
    return null;
  }
}
