import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/relationship_repository.dart';
import '../../data/models/relationship_model.dart';
import 'bloc.dart';

class RelationshipBloc extends Bloc<RelationshipEvent, RelationshipState> {
  final RelationshipRepository repository;

  RelationshipBloc({required this.repository}) : super(RelationshipInitial()) {
    on<LoadRelationshipsEvent>(_onLoadRelationships);
    on<AddRelationshipEvent>(_onAddRelationship);
    on<RemoveRelationshipEvent>(_onRemoveRelationship);
    on<ValidateRelationshipEvent>(_onValidateRelationship);
  }

  /// Load relationships
  Future<void> _onLoadRelationships(
    LoadRelationshipsEvent event,
    Emitter<RelationshipState> emit,
  ) async {
    try {
      emit(RelationshipsLoading());

      List<Relationship> relationships;

      if (event.personId != null) {
        // Load relationships for specific person (both as parent and child)
        final asParent = await repository.getRelationshipsByParentId(event.personId!);
        final asChild = await repository.getRelationshipsByChildId(event.personId!);
        relationships = [...asParent, ...asChild];
      } else {
        // Load all relationships
        relationships = await repository.getAllRelationships();
      }

      emit(RelationshipsLoaded(relationships: relationships));
    } catch (e) {
      emit(RelationshipError(message: e.toString()));
    }
  }

  /// Add new relationship
  Future<void> _onAddRelationship(
    AddRelationshipEvent event,
    Emitter<RelationshipState> emit,
  ) async {
    try {
      print('═══════════════════════════════════════════════════');
      print('ADDING RELATIONSHIP:');
      print('  - Person 1: ${event.parentId}');
      print('  - Person 2: ${event.childId}');
      print('  - Type: ${event.type}');
      if (event.weddingDate != null) print('  - Wedding Date: ${event.weddingDate}');
      
      emit(RelationshipsLoading());

      final relationship = await repository.addRelationship(
        parentId: event.parentId,
        childId: event.childId,
        type: event.type,
        weddingDate: event.weddingDate,
      );

      print('✅ SUCCESS: Relationship added with ID: ${relationship.id}');
      print('═══════════════════════════════════════════════════');

      emit(RelationshipAdded(relationship: relationship));
      
      // Reload relationships after adding
      add(LoadRelationshipsEvent());
    } catch (e) {
      print('❌ ERROR adding relationship: $e');
      print('═══════════════════════════════════════════════════');
      emit(RelationshipError(message: e.toString()));
    }
  }

  /// Remove relationship
  Future<void> _onRemoveRelationship(
    RemoveRelationshipEvent event,
    Emitter<RelationshipState> emit,
  ) async {
    try {
      print('REMOVING RELATIONSHIP: ${event.relationshipId}');
      await repository.deleteRelationship(event.relationshipId);
      emit(RelationshipRemoved(relationshipId: event.relationshipId));
      
      // Reload relationships after removing
      add(LoadRelationshipsEvent());
    } catch (e) {
      print('❌ ERROR removing relationship: $e');
      emit(RelationshipError(message: e.toString()));
    }
  }

  /// Validate relationship before adding
  Future<void> _onValidateRelationship(
    ValidateRelationshipEvent event,
    Emitter<RelationshipState> emit,
  ) async {
    try {
      print('VALIDATING RELATIONSHIP: ${event.parentId} -> ${event.childId} (${event.type})');
      
      // Check if same person
      if (event.parentId == event.childId) {
        print('⚠️ Validation failed: Same person');
        emit(const RelationshipValidated(
          isValid: false,
          errorMessage: 'A person cannot be their own relationship partner',
        ));
        return;
      }

      // Check if relationship already exists
      final existing = await repository.getAllRelationships();
      final exists = existing.any(
        (r) => r.parentId == event.parentId && r.childId == event.childId && r.type == event.type,
      );

      if (exists) {
        print('⚠️ Validation failed: Relationship already exists');
        emit(const RelationshipValidated(
          isValid: false,
          errorMessage: 'This relationship already exists',
        ));
        return;
      }

      // For parent-child, check for circular dependency
      if (event.type == 'parent-child') {
        final parentAsChild = await _getParentId(event.parentId);
        if (parentAsChild == event.childId) {
          print('⚠️ Validation failed: Circular dependency');
          emit(const RelationshipValidated(
            isValid: false,
            errorMessage: 'Cannot create circular dependency',
          ));
          return;
        }
      }

      print('✅ Validation successful');

      // Validation passed
      emit(const RelationshipValidated(isValid: true));
    } catch (e) {
      emit(RelationshipError(message: e.toString()));
    }
  }

  /// Helper to get direct parent
  Future<String?> _getParentId(String childId) async {
    try {
      final relationships = await repository.getRelationshipsByChildId(childId);
      if (relationships.isNotEmpty) {
        return relationships.first.parentId;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
