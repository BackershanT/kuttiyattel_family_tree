// Relationship Model
class Relationship {
  final String id;
  final String parentId;
  final String childId;

  Relationship({
    required this.id,
    required this.parentId,
    required this.childId,
  });

  factory Relationship.fromMap(Map<String, dynamic> map) {
    return Relationship(
      id: map['id'] as String,
      parentId: map['parent_id'] as String,
      childId: map['child_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'child_id': childId,
    };
  }
}
