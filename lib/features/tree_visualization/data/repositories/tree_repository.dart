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
    // 1. Find all people who are children
    final childIds = relationships
        .where((r) => r.type == 'parent-child')
        .map((r) => r.childId)
        .toSet();

    // 2. Find all people who are the 'childId' in a spouse relationship 
    // (This helps pick only ONE of a couple as the root)
    final spouseIds = relationships
        .where((r) => r.type == 'spouse')
        .map((r) => r.childId)
        .toSet();

    // Roots are people who are NOT children AND NOT the 'spouse' entry (the second person in a couple)
    return persons.where((p) => !childIds.contains(p.id) && !spouseIds.contains(p.id)).toList();
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

    // Create a map for quick relationship lookup
    // 1. Parent-child relationships for the hierarchical tree
    final parentChildMap = <String, List<String>>{};
    for (var rel in relationships.where((r) => r.type == 'parent-child')) {
      parentChildMap.putIfAbsent(rel.parentId, () => []).add(rel.childId);
    }

    // 2. Spouse relationships for horizontal placement
    final spouseMap = <String, String>{};
    for (var rel in relationships.where((r) => r.type == 'spouse')) {
      // Store both ways to simplify lookup
      spouseMap[rel.parentId] = rel.childId;
      spouseMap[rel.childId] = rel.parentId;
    }

    // Find root persons
    final roots = findRootPersons(persons, relationships);

    if (roots.isEmpty) {
      return null;
    }

    // If multiple roots, create a virtual root
    if (roots.length > 1) {
      return _buildMultiRootTree(roots, personMap, parentChildMap, spouseMap);
    }

    // Single root - build tree normally
    return _buildTreeFromNode(roots.first.id, personMap, parentChildMap, spouseMap, 0);
  }

  /// Build tree with multiple roots (virtual root)
  TreeNodeData _buildMultiRootTree(
    List<Person> roots,
    Map<String, Person> personMap,
    Map<String, List<String>> parentChildMap,
    Map<String, String> spouseMap,
  ) {
    // Create a virtual root node
    final virtualRoot = TreeNodeData(
      person: Person(
        id: 'virtual_root',
        name: 'Family Root',
        gender: 'Unknown',
      ),
      children: roots.map((root) {
        return _buildTreeFromNode(root.id, personMap, parentChildMap, spouseMap, 1);
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
    Map<String, String> spouseMap,
    int depth,
  ) {
    final person = personMap[personId];
    if (person == null) {
      throw Exception('Person not found: $personId');
    }

    // Find spouse
    final spouseId = spouseMap[personId];
    final spouse = spouseId != null ? personMap[spouseId] : null;

    final children = <TreeNodeData>[];
    final childIds = parentChildMap[personId] ?? [];
    
    // Also check spouse's children if any (for combined family view)
    if (spouseId != null && parentChildMap.containsKey(spouseId)) {
      for (final sChildId in parentChildMap[spouseId]!) {
        if (!childIds.contains(sChildId)) {
          childIds.add(sChildId);
        }
      }
    }

    for (final childId in childIds) {
      children.add(_buildTreeFromNode(childId, personMap, parentChildMap, spouseMap, depth + 1));
    }

    return TreeNodeData(
      person: person,
      spouse: spouse,
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
