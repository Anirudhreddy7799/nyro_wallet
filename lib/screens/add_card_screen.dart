import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCardScreen extends StatefulWidget {
  static const routeName = '/add-card';
  const AddCardScreen({Key? key}) : super(key: key);

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController =
      TextEditingController(); // Accepts MMYY, MM/YY, or MM/YYYY
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  final _nicknameController =
      TextEditingController(); // Add nickname controller

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    _nicknameController.dispose(); // Dispose nickname controller
    super.dispose();
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter expiry date';
    }
    final input = value.trim();
    int month;
    int yearFull;

    if (RegExp(r'^\d{4}').hasMatch(input)) {
      month = int.parse(input.substring(0, 2));
      final yy = int.parse(input.substring(2, 4));
      yearFull = 2000 + yy;
    } else if (RegExp(r'^\d{2}/\d{2}$').hasMatch(input)) {
      month = int.parse(input.substring(0, 2));
      final yy = int.parse(input.substring(3, 5));
      yearFull = 2000 + yy;
    } else if (RegExp(r'^\d{2}/\d{4}$').hasMatch(input)) {
      month = int.parse(input.substring(0, 2));
      yearFull = int.parse(input.substring(3, 7));
    } else {
      return 'Invalid format. Use MMYY, MM/YY or MM/YYYY';
    }

    if (month < 1 || month > 12) {
      return 'Month must be between 01 and 12';
    }

    final now = DateTime.now();
    final lastDayOfMonth = DateTime(yearFull, month + 1, 0);
    if (lastDayOfMonth.isBefore(now)) {
      return 'Card expired';
    }

    return null;
  }

  String? _validateCardNumber(String? value) {
    if (value == null) return 'Enter card number';
    final digitsOnly = value.replaceAll(RegExp(r'\s+'), '');
    if (digitsOnly.length != 16) return 'Card number must be 16 digits';
    if (!RegExp(r'^[0-9]{16}$').hasMatch(digitsOnly)) {
      return 'Only digits allowed';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'Enter CVV';
    if (value.length != 3) return 'CVV must be 3 digits';
    if (!RegExp(r'^[0-9]{3}$').hasMatch(value)) return 'Invalid CVV';
    return null;
  }

  String? _validateHolderName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter cardholder name';
    return null;
  }

  Future<void> _saveCard() async {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMsg = 'No user is signed in.';
        _isLoading = false;
      });
      return;
    }

    final rawNumber = _cardNumberController.text.trim();
    final rawExpiry = _expiryController.text.trim();
    final holder = _cardHolderNameController.text.trim();
    final nickname = _nicknameController.text.trim(); // Get nickname

    int month;
    int yearFull;
    if (RegExp(r'^\d{4}$').hasMatch(rawExpiry)) {
      month = int.parse(rawExpiry.substring(0, 2));
      final yy = int.parse(rawExpiry.substring(2, 4));
      yearFull = 2000 + yy;
    } else if (RegExp(r'^\d{2}/\d{2}$').hasMatch(rawExpiry)) {
      month = int.parse(rawExpiry.substring(0, 2));
      final yy = int.parse(rawExpiry.substring(3, 5));
      yearFull = 2000 + yy;
    } else {
      month = int.parse(rawExpiry.substring(0, 2));
      yearFull = int.parse(rawExpiry.substring(3, 7));
    }

    final yearTwoDigit = yearFull % 100;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .add({
            'cardHolderName': holder,
            'cardNumber': rawNumber.replaceAll(RegExp(r'\s+'), ''),
            'expiryMonth': month,
            'expiryYear': yearTwoDigit,
            'nickname': nickname.isNotEmpty ? nickname : null, // Save nickname
            'createdAt': FieldValue.serverTimestamp(),
          });

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Card added successfully!',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.amber,
          duration: Duration(seconds: 1),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _errorMsg = 'Failed to add card: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Add Card', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                validator: _validateCardNumber,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MMYY  or  MM/YY  or  MM/YYYY',
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                validator: _validateExpiry,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
                validator: _validateCvv,
              ),
              const SizedBox(height: 12),
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
                validator: _validateHolderName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname (optional)',
                  hintText: 'e.g. “Business Card” or “Gym Card”',
                  filled: true,
                  fillColor: Colors.white24,
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              if (_errorMsg != null) ...[
                Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _saveCard,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Card',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
