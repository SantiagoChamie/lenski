import 'dart:ui';

class Course {
  int? id;
  String name;
  String level;
  String code;
  bool listening;
  bool speaking;
  bool reading;
  bool writing;
  Color color;
  String imageUrl;

  Course({
    this.id,
    required this.name,
    required this.level,
    required this.code,
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
      "id": id,
      'name': name,
      'level': level,
      'code': code,
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
      id: map['id'],
      name: map['name'],
      level: map['level'],
      code: map['code'],
      listening: map['listening'] == 1,
      speaking: map['speaking'] == 1,
      reading: map['reading'] == 1,
      writing: map['writing'] == 1,
      color: Color(map['color']),
      imageUrl: map['imageUrl'],
    );
  }
}