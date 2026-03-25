import '../../../persons/data/models/person_model.dart';

/// Represents a node in the family tree hierarchy
class TreeNodeData {
  final Person person;
  final Person? spouse;
  final List<TreeNodeData> children;
  bool isExpanded;
  final int depth;

  TreeNodeData({
    required this.person,
    this.spouse,
    this.children = const [],
    this.isExpanded = true,
    this.depth = 0,
  });

  /// Get all descendants recursively
  List<TreeNodeData> getAllDescendants() {
    final result = <TreeNodeData>[];
    for (final child in children) {
      result.add(child);
      result.addAll(child.getAllDescendants());
    }
    return result;
  }

  /// Get total descendant count
  int get descendantCount {
    int count = children.length;
    for (final child in children) {
      count += child.descendantCount;
    }
    return count;
  }

  @override
  String toString() => 'TreeNode(person: ${person.name}, children: ${children.length})';
}
