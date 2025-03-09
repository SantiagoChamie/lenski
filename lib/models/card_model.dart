class Card {
  final int? id;
  final String front;
  final String back;
  final String context;
  final DateTime dueDate;
  final String language;

  Card({
    this.id,
    required this.front,
    required this.back,
    required this.context,
    required this.dueDate,
    required this.language,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'front': front,
      'back': back,
      'context': context,
      'dueDate': dueDate.toIso8601String(), // Convert DateTime to ISO 8601 string
      'language': language,
    };
  }

  factory Card.fromMap(Map<String, dynamic> map) {
    return Card(
      id: map['id'],
      front: map['front'],
      back: map['back'],
      context: map['context'],
      dueDate: DateTime.parse(map['dueDate']), // Parse ISO 8601 string to DateTime
      language: map['language'],
    );
  }
}