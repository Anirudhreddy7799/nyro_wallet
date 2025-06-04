import '../models/card_model.dart';

class InMemoryDB {
  InMemoryDB._(); // private constructor
  static final InMemoryDB instance = InMemoryDB._();

  final List<CardModel> cards = [];
}
