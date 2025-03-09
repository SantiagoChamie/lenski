import 'dart:ui';

class Card {
  int? id;
  String front;
  String back;
  String context;
  DateTime dueDate;
  String language;

  Card({
    required this.id,
    required this.front,
    required this.back,
    required this.context,
    required this.dueDate,
    required this.language,
  });
  // Convert a Card into a Map. The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'front': front,
      'level': back,
      'context': context,
      'dueDate': dueDate,
      'language': language,
    };
  }

  // Extract a Card object from a Map.
  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      front: map['front'],
      back: map['back'],
      context: map['context'],
      dueDate: map['dueDate'],
      language: map['language'],
    );
  }
}