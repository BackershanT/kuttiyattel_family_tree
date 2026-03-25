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
    String type = 'parent-child',
    DateTime? weddingDate,
  }) async {
    try {
      // Validate: Check if relationship already exists
      final existing = await _client
          .from(SupabaseConfig.relationshipsTable)
          .select()
          .eq('parent_id', parentId)
          .eq('child_id', childId)
          .eq('relationship_type', type)
          .maybeSingle();

      if (existing != null) {
        throw Exception('This relationship already exists');
      }

      // Validate: Cannot be your own parent
      if (parentId == childId) {
        throw Exception('A person cannot be their own kind of relationship with themselves');
      }

      final data = {
        'parent_id': parentId,
        'child_id': childId,
        'relationship_type': type,
      };

      final response = await _client
          .from(SupabaseConfig.relationshipsTable)
          .insert(data)
          .select()
          .single();

      final relationship = Relationship.fromMap(response);

      // If it's a spouse relationship and has a wedding date, add to events table
      if (type == 'spouse' && weddingDate != null) {
        // Fetch names for the event title
        final p1Response = await _client.from(SupabaseConfig.personsTable).select('name').eq('id', parentId).single();
        final p2Response = await _client.from(SupabaseConfig.personsTable).select('name').eq('id', childId).single();
        
        final String p1Name = p1Response['name'] as String;
        final String p2Name = p2Response['name'] as String;

        await _client.from('events').insert({
          'title': '$p1Name & $p2Name\'s Wedding Anniversary',
          'event_date': weddingDate.toIso8601String().split('T')[0],
          'type': 'wedding_anniversary',
          'recurrence': 'yearly',
          'relationship_id': relationship.id,
        });
      }

      return relationship;
    } catch (e) {
      throw Exception('Failed to add relationship: $e');
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
