import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../persons/data/models/person_model.dart';
import '../../../relationships/data/models/relationship_model.dart';
import '../models/tree_node_data.dart';

class TreeRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Fetch all persons from database
  Future<List<Person>> getAllPersons() async {
    try {
      final response = await _client
          .from(SupabaseConfig.personsTable)
          .select()
          .order('dob', ascending: true);

      return (response as List).map((p) => Person.fromMap(p)).toList();
    } catch (e) {
      throw Exception('Failed to load persons: $e');
    }
  }

  /// Fetch all relationships from database
  Future<List<Relationship>> getAllRelationships() async {
    try {
      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select();

      return (response as List).map((r) => Relationship.fromMap(r)).toList();
    } catch (e) {
      throw Exception('Failed to load relationships: $e');
    }
  }

  /// Find root persons (those who are not children of anyone)
  List<Person> findRootPersons(List<Person> persons, List<Relationship> relationships) {
    final childIds = relationships.map((r) => r.childId).toSet();
    return persons.where((p) => !childIds.contains(p.id)).toList();
  }

  /// Build the complete family tree structure
  Future<TreeNodeData?> buildFamilyTree() async {
    final persons = await getAllPersons();
    final relationships = await getAllRelationships();

    if (persons.isEmpty) {
      return null;
    }

    // Create a map for quick person lookup
    final personMap = {for (var p in persons) p.id: p};

    // Create a map for quick relationship lookup (parent -> children)
    final parentChildMap = <String, List<String>>{};
    for (var rel in relationships) {
      parentChildMap.putIfAbsent(rel.parentId, () => []).add(rel.childId);
    }

    // Find root persons
    final roots = findRootPersons(persons, relationships);

    if (roots.isEmpty) {
      return null;
    }

    // If multiple roots, create a virtual root
    if (roots.length > 1) {
      return _buildMultiRootTree(roots, personMap, parentChildMap);
    }

    // Single root - build tree normally
    return _buildTreeFromNode(roots.first.id, personMap, parentChildMap, 0);
  }

  /// Build tree with multiple roots (virtual root)
  TreeNodeData _buildMultiRootTree(
    List<Person> roots,
    Map<String, Person> personMap,
    Map<String, List<String>> parentChildMap,
  ) {
    // Create a virtual root node
    final virtualRoot = TreeNodeData(
      person: Person(
        id: 'virtual_root',
        name: 'Family Root',
        gender: 'Unknown',
      ),
      children: roots.map((root) {
        return _buildTreeFromNode(root.id, personMap, parentChildMap, 1);
      }).toList(),
      isExpanded: true,
      depth: 0,
    );

    return virtualRoot;
  }

  /// Recursively build tree from a specific person
  TreeNodeData _buildTreeFromNode(
    String personId,
    Map<String, Person> personMap,
    Map<String, List<String>> parentChildMap,
    int depth,
  ) {
    final person = personMap[personId];
    if (person == null) {
      throw Exception('Person not found: $personId');
    }

    final children = <TreeNodeData>[];
    final childIds = parentChildMap[personId] ?? [];

    for (final childId in childIds) {
      children.add(_buildTreeFromNode(childId, personMap, parentChildMap, depth + 1));
    }

    return TreeNodeData(
      person: person,
      children: children,
      isExpanded: true, // Default expanded
      depth: depth,
    );
  }

  /// Get person by ID
  Future<Person?> getPersonById(String id) async {
    try {
      final response = await _client
          .from(SupabaseConfig.personsTable)
          .select()
          .eq('id', id)
          .single();

      return response != null ? Person.fromMap(response) : null;
    } catch (e) {
      return null;
    }
  }
}
