import 'package:equatable/equatable.dart';
import '../../data/models/person_model.dart';

abstract class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object?> get props => [];
}

class PersonInitial extends PersonState {}

class PersonsLoading extends PersonState {}

class PersonsLoaded extends PersonState {
  final List<Person> persons;

  const PersonsLoaded({required this.persons});

  @override
  List<Object?> get props => [persons];
}

class PersonAdded extends PersonState {
  final Person person;

  const PersonAdded({required this.person});

  @override
  List<Object?> get props => [person];
}

class PersonUpdated extends PersonState {
  final Person person;

  const PersonUpdated({required this.person});

  @override
  List<Object?> get props => [person];
}

class PersonDeleted extends PersonState {}

class PersonsError extends PersonState {
  final String message;

  const PersonsError({required this.message});

  @override
  List<Object?> get props => [message];
}
