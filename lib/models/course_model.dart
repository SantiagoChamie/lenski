import 'dart:ui';

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
  // Convert a Course into a Map. The keys must correspond to the names of the columns in the database.
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

  // Extract a Course object from a Map.
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