// Person Model
class Person {
  final String id;
  final String name;
  final String? gender;
  final DateTime? dateOfBirth;
  final DateTime? dateOfDeath;
  final String? photoUrl;
  final DateTime? createdAt;

  Person({
    required this.id,
    required this.name,
    this.gender,
    this.dateOfBirth,
    this.dateOfDeath,
    this.photoUrl,
    this.createdAt,
  });

  factory Person.fromMap(Map<String, dynamic> map) {
    return Person(
      id: map['id'] as String,
      name: map['name'] as String,
      gender: map['gender'] as String?,
      dateOfBirth: map['dob'] != null 
          ? DateTime.parse(map['dob'] as String) 
          : null,
      dateOfDeath: map['dod'] != null 
          ? DateTime.parse(map['dod'] as String) 
          : null,
      photoUrl: map['photo_url'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'dob': dateOfBirth?.toIso8601String(),
      'dod': dateOfDeath?.toIso8601String(),
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Person(id: $id, name: $name)';
}
