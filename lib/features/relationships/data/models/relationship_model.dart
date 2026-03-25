// Relationship Model
class Relationship {
  final String id;
  final String parentId;
  final String childId;
  final String? type; // 'parent-child', 'spouse', etc.

  Relationship({
    required this.id,
    required this.parentId,
    required this.childId,
    this.type = 'parent-child',
  });

  factory Relationship.fromMap(Map<String, dynamic> map) {
    return Relationship(
      id: map['id'] as String,
      parentId: map['parent_id'] as String,
      childId: map['child_id'] as String,
      type: map['relationship_type'] as String? ?? 'parent-child',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parent_id': parentId,
      'child_id': childId,
      'relationship_type': type,
    };
  }
}
