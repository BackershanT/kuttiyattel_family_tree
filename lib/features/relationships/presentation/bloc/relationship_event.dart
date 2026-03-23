import 'package:equatable/equatable.dart';

abstract class RelationshipEvent extends Equatable {
  const RelationshipEvent();

  @override
  List<Object?> get props => [];
}

/// Load all relationships or relationships for a specific person
class LoadRelationshipsEvent extends RelationshipEvent {
  final String? personId; // null = load all

  const LoadRelationshipsEvent({this.personId});

  @override
  List<Object?> get props => [personId];
}

/// Add a new parent-child relationship
class AddRelationshipEvent extends RelationshipEvent {
  final String parentId;
  final String childId;

  const AddRelationshipEvent({
    required this.parentId,
    required this.childId,
  });

  @override
  List<Object?> get props => [parentId, childId];
}

/// Remove an existing relationship
class RemoveRelationshipEvent extends RelationshipEvent {
  final String relationshipId;

  const RemoveRelationshipEvent({required this.relationshipId});

  @override
  List<Object?> get props => [relationshipId];
}

/// Validate a potential relationship before adding
class ValidateRelationshipEvent extends RelationshipEvent {
  final String parentId;
  final String childId;

  const ValidateRelationshipEvent({
    required this.parentId,
    required this.childId,
  });

  @override
  List<Object?> get props => [parentId, childId];
}
