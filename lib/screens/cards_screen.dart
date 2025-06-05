import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:credit_card_type_detector/credit_card_type_detector.dart';

import 'add_card_screen.dart';
import 'edit_card_screen.dart';
import '../utils/card_utils.dart';

class CardsScreen extends StatelessWidget {
  static const routeName = '/cards';

  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cards'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No cards added yet.\nTap + to add one.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final cards = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: cards.length,
            itemBuilder: (ctx, i) {
              final card = cards[i];
              final cardData = card.data() as Map<String, dynamic>;

              return CardTile(cardId: card.id, cardData: cardData);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber[700],
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(AddCardScreen.routeName);
        },
      ),
    );
  }
}

class CardTile extends StatelessWidget {
  final String cardId;
  final Map<String, dynamic> cardData;

  const CardTile({required this.cardId, required this.cardData, Key? key})
    : super(key: key);

  String _maskedNumber(String fullNumber) {
    final last4 = fullNumber.length >= 4
        ? fullNumber.substring(fullNumber.length - 4)
        : fullNumber;
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    final cardNumber = cardData['cardNumber'] as String? ?? '';
    final expiryMonth = cardData['expiryMonth'] as int?;
    final expiryYear = cardData['expiryYear'] as int?;
    final nickname = (cardData['nickname'] as String?)?.trim();
    final cardType = detectCCType(cardNumber.replaceAll(RegExp(r'\s+'), ''));
    final maskedNum = _maskedNumber(cardNumber);

    String expiryText = 'Exp: ';
    if (expiryMonth != null && expiryYear != null) {
      final mm = expiryMonth.toString().padLeft(2, '0');
      final yyyy = expiryYear.toString();
      expiryText += '$mm/$yyyy';
    } else {
      expiryText += 'N/A';
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          EditCardScreen.routeName,
          arguments: {'cardId': cardId, 'cardData': cardData},
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        cardTypeIcon(cardType),
                        const SizedBox(width: 8),
                        Text(
                          maskedNum,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nickname?.isNotEmpty == true ? nickname! : 'No nickname',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expiryText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('cards')
                      .doc(cardId)
                      .delete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
