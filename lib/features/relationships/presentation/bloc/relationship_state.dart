import 'package:equatable/equatable.dart';
import '../../data/models/relationship_model.dart';

abstract class RelationshipState extends Equatable {
  const RelationshipState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RelationshipInitial extends RelationshipState {}

/// Loading relationships
class RelationshipsLoading extends RelationshipState {}

/// Relationships loaded successfully
class RelationshipsLoaded extends RelationshipState {
  final List<Relationship> relationships;

  const RelationshipsLoaded({required this.relationships});

  @override
  List<Object?> get props => [relationships];
}

/// Relationship added successfully
class RelationshipAdded extends RelationshipState {
  final Relationship relationship;

  const RelationshipAdded({required this.relationship});

  @override
  List<Object?> get props => [relationship];
}

/// Relationship removed successfully
class RelationshipRemoved extends RelationshipState {
  final String relationshipId;

  const RelationshipRemoved({required this.relationshipId});

  @override
  List<Object?> get props => [relationshipId];
}

/// Relationship validation result
class RelationshipValidated extends RelationshipState {
  final bool isValid;
  final String? errorMessage;

  const RelationshipValidated({
    required this.isValid,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isValid, errorMessage];
}

/// Error state
class RelationshipError extends RelationshipState {
  final String message;

  const RelationshipError({required this.message});

  @override
  List<Object?> get props => [message];
}
