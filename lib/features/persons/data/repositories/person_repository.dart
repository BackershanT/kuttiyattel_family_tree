import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/person_model.dart';
import '../../../../core/config/supabase_config.dart';

class PersonRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // Get all persons
  Future<List<Person>> getAllPersons() async {
    try {
      final response = await _client
          .from(SupabaseConfig.personsTable)
          .select()
          .order('name');

      return (response as List).map((p) => Person.fromMap(p)).toList();
    } catch (e) {
      throw Exception('Failed to load persons: $e');
    }
  }

  // Get person by ID
  Future<Person?> getPersonById(String id) async {
    try {
      final response = await _client
          .from(SupabaseConfig.personsTable)
          .select()
          .eq('id', id)
          .single();

      return response != null ? Person.fromMap(response) : null;
    } catch (e) {
      throw Exception('Failed to get person: $e');
    }
  }

  // Add new person
  Future<Person> addPerson({
    required String name,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
  }) async {
    try {
      final data = {
        'name': name,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'dob': dateOfBirth.toIso8601String(),
        if (photoUrl != null) 'photo_url': photoUrl,
      };

      final response = await _client
          .from(SupabaseConfig.personsTable)
          .insert(data)
          .select()
          .single();

      return Person.fromMap(response);
    } catch (e) {
      throw Exception('Failed to add person: $e');
    }
  }

  // Update person
  Future<Person> updatePerson({
    required String id,
    required String name,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
  }) async {
    try {
      final data = {
        'name': name,
        if (gender != null) 'gender': gender,
        if (dateOfBirth != null) 'dob': dateOfBirth.toIso8601String(),
        if (photoUrl != null) 'photo_url': photoUrl,
      };

      final response = await _client
          .from(SupabaseConfig.personsTable)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return Person.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update person: $e');
    }
  }

  // Delete person
  Future<void> deletePerson(String id) async {
    try {
      await _client
          .from(SupabaseConfig.personsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete person: $e');
    }
  }

  // Search persons by name
  Future<List<Person>> searchPersons(String query) async {
    try {
      final response = await _client
          .from(SupabaseConfig.personsTable)
          .select()
          .ilike('name', '%$query%')
          .order('name');

      return (response as List).map((p) => Person.fromMap(p)).toList();
    } catch (e) {
      throw Exception('Failed to search persons: $e');
    }
  }
}
