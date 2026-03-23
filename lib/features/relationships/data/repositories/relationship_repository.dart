import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../models/relationship_model.dart';

class RelationshipRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Get all relationships
  Future<List<Relationship>> getAllRelationships() async {
    try {
      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select()
          .order('created_at');

      return (response as List).map((r) => Relationship.fromMap(r)).toList();
    } catch (e) {
      throw Exception('Failed to load relationships: $e');
    }
  }

  // Get relationships by parent ID
  Future<List<Relationship>> getRelationshipsByParentId(String parentId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select()
          .eq('parent_id', parentId)
          .order('created_at');

      return (response as List).map((r) => Relationship.fromMap(r)).toList();
    } catch (e) {
      throw Exception('Failed to load relationships: $e');
    }
  }

  // Get relationships by child ID
  Future<List<Relationship>> getRelationshipsByChildId(String childId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select()
          .eq('child_id', childId)
          .order('created_at');

      return (response as List).map((r) => Relationship.fromMap(r)).toList();
    } catch (e) {
      throw Exception('Failed to load relationships: $e');
    }
  }

  // Add new relationship
  Future<Relationship> addRelationship({
    required String parentId,
    required String childId,
  }) async {
    try {
      // Validate: Check if relationship already exists
      final existing = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select()
          .eq('parent_id', parentId)
          .eq('child_id', childId)
          .maybeSingle();

      if (existing != null) {
        throw Exception('This relationship already exists');
      }

      // Validate: Cannot be your own parent
      if (parentId == childId) {
        throw Exception('A person cannot be their own parent');
      }

      // Validate: Prevent circular relationships (simple check)
      final parentAsChild = await _getDirectParent(parentId);
      if (parentAsChild == childId) {
        throw Exception(
            'Cannot create relationship: This would create a circular dependency');
      }

      final data = {
        'parent_id': parentId,
        'child_id': childId,
      };

      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .insert(data)
          .select()
          .single();

      return Relationship.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add relationship: $e');
    }
  }

  // Helper method to get direct parent
  Future<String?> _getDirectParent(String childId) async {
    try {
      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select('parent_id')
          .eq('child_id', childId)
          .maybeSingle();

      return response?['parent_id'] as String?;
    } catch (e) {
      return null;
    }
  }

  // Delete relationship
  Future<void> deleteRelationship(String id) async {
    try {
      await _client
          .from(SupabaseConfig.relationshipsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete relationship: $e');
    }
  }

  // Delete relationship by parent and child IDs
  Future<void> deleteRelationshipByPair({
    required String parentId,
    required String childId,
  }) async {
    try {
      await _client
          .from(SupabaseConfig.relationshipsTable)
          .delete()
          .eq('parent_id', parentId)
          .eq('child_id', childId);
    } catch (e) {
      throw Exception('Failed to delete relationship: $e');
    }
  }
}
