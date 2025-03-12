/// Sentence model class
/// The id represents its position in the book
class Sentence {
  int id;
  String sentence;
  
  /// Creates a Sentence object.
  /// 
  /// [id] is the unique identifier for the sentence, representing its position in the book.
  /// [sentence] is the text of the sentence.
  Sentence({
    required this.id,
    required this.sentence,
  });
  
  /// Converts a Sentence object into a Map.
  /// The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sentence': sentence,
    };
  }

  /// Extracts a Sentence object from a Map.
  factory Sentence.fromMap(Map<String, dynamic> map) {
    return Sentence(
      id: map['id'],
      sentence: map['sentence'],
    );
  }
}