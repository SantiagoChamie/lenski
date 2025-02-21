import 'dart:ui';

class Course {
  String name;
  String level;
  String code;
  bool listening;
  bool speaking;
  bool reading;
  bool writing;
  int position; 
  Color color;
  String imageUrl;

  Course({
    required this.name,
    required this.level,
    required this.code,
    required this.listening,
    required this.speaking,
    required this.reading,
    required this.writing,
    required this.position,
    required this.color,
    required this.imageUrl,
  });
}