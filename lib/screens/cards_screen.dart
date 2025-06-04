import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_card_screen.dart';

class CardsScreen extends StatelessWidget {
  static const routeName = '/cards';

  const CardsScreen({super.key});

  Future<void> _deleteCard(String cardId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cards')
          .doc(cardId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting card: $e');
    }
  }

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

              final fullNumber = cardData['cardNumber'] as String? ?? '';
              final last4 = fullNumber.length >= 4
                  ? fullNumber.substring(fullNumber.length - 4)
                  : fullNumber;

              final nicknameRaw = cardData['nickname'] as String?;
              final displayNickname =
                  (nicknameRaw == null || nicknameRaw.trim().isEmpty)
                  ? 'No nickname'
                  : nicknameRaw.trim();

              final expiryMonth = cardData['expiryMonth'] as int?;
              final expiryYear = cardData['expiryYear'] as int?;
              String expiryDisplay;
              if (expiryMonth == null || expiryYear == null) {
                expiryDisplay = 'Exp: --/--';
              } else {
                final mm = expiryMonth.toString().padLeft(2, '0');
                final yy = expiryYear.toString().padLeft(2, '0');
                expiryDisplay = 'Exp: $mm/$yy';
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text('•••• •••• •••• $last4'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(displayNickname), Text(expiryDisplay)],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCard(card.id),
                  ),
                ),
              );
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
