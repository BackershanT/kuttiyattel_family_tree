import 'package:equatable/equatable.dart';

abstract class PersonEvent extends Equatable {
  const PersonEvent();

  @override
  List<Object?> get props => [];
}

class LoadPersonsEvent extends PersonEvent {}

class AddPersonEvent extends PersonEvent {
  final String name;
  final String? gender;
  final DateTime? dateOfBirth;
  final DateTime? marriageDate;
  final DateTime? dateOfDeath;
  final String? photoUrl;

  const AddPersonEvent({
    required this.name,
    this.gender,
    this.dateOfBirth,
    this.marriageDate,
    this.dateOfDeath,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, gender, dateOfBirth, marriageDate, dateOfDeath, photoUrl];
}

class UpdatePersonEvent extends PersonEvent {
  final String id;
  final String name;
  final String? gender;
  final DateTime? dateOfBirth;
  final DateTime? marriageDate;
  final DateTime? dateOfDeath;
  final String? photoUrl;

  const UpdatePersonEvent({
    required this.id,
    required this.name,
    this.gender,
    this.dateOfBirth,
    this.marriageDate,
    this.dateOfDeath,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, gender, dateOfBirth, marriageDate, dateOfDeath, photoUrl];
}

class DeletePersonEvent extends PersonEvent {
  final String id;

  const DeletePersonEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

class SearchPersonsEvent extends PersonEvent {
  final String query;

  const SearchPersonsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}
