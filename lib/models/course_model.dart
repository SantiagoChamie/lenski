import 'dart:ui';

/// A model class representing a course.
class Course {
  String name;
  String level;
  String code;
  String fromCode;
  bool listening;
  bool speaking;
  bool reading;
  bool writing;
  Color color;
  String imageUrl;

  /// Creates a Course object.
  /// 
  /// [name] is the name of the course.
  /// [level] is the level of the course.
  /// [code] is the language code of the course.
  /// [fromCode] is the language code from which the course is being learned.
  /// [listening] indicates if the course includes listening competence.
  /// [speaking] indicates if the course includes speaking competence.
  /// [reading] indicates if the course includes reading competence.
  /// [writing] indicates if the course includes writing competence.
  /// [color] is the color associated with the course.
  /// [imageUrl] is the URL of the course's image.
  Course({
    required this.name,
    required this.level,
    required this.code,
    required this.fromCode,
    required this.listening,
    required this.speaking,
    required this.reading,
    required this.writing,
    required this.color,
    required this.imageUrl,
  });

  /// Converts a Course object into a Map.
  /// The keys must correspond to the names of the columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'code': code,
      'fromCode': fromCode,
      'listening': listening ? 1 : 0,
      'speaking': speaking ? 1 : 0,
      'reading': reading ? 1 : 0,
      'writing': writing ? 1 : 0,
      'color': color.value,
      'imageUrl': imageUrl,
    };
  }

  /// Extracts a Course object from a Map.
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'],
      level: map['level'],
      code: map['code'],
      fromCode: map['fromCode'],
      listening: map['listening'] == 1,
      speaking: map['speaking'] == 1,
      reading: map['reading'] == 1,
      writing: map['writing'] == 1,
      color: Color(map['color']),
      imageUrl: map['imageUrl'],
    );
  }
}