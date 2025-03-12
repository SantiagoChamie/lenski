/// Sentence model class
/// The id represents its position in the book
class Sentence {
  int id;
  String sentence;
  
  Sentence({
    required this.id,
    required this.sentence,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sentence': sentence,
    };
  }

  factory Sentence.fromMap(Map<String, dynamic> map) {
    return Sentence(
      id: map['id'],
      sentence: map['sentence'],
    );
  }
}