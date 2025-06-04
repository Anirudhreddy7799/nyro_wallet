import 'package:flutter/material.dart';
import 'add_card_screen.dart';
import '../data/in_memory_db.dart';
import '../models/card_model.dart';

class CardsScreen extends StatelessWidget {
  static const routeName = '/cards';

  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cards'),
        backgroundColor: Colors.black,
      ),
      body: const _CardsList(),
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

class _CardsList extends StatelessWidget {
  const _CardsList({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = InMemoryDB.instance.cards;

    if (cards.isEmpty) {
      return const Center(
        child: Text(
          'No cards added yet.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cards.length,
      itemBuilder: (ctx, i) {
        final CardModel card = cards[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.credit_card),
            title: Text(
              '•••• •••• •••• ${card.number.substring(card.number.length - 4)}',
            ),
            subtitle: Text('${card.cardHolder}   Exp: ${card.expiry}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Card tapped (no action yet)')),
              );
            },
          ),
        );
      },
    );
  }
}
