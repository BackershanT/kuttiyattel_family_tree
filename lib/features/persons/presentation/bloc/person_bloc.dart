import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/models/person_model.dart';
import 'bloc.dart';

class PersonBloc extends Bloc<PersonEvent, PersonState> {
  final PersonRepository repository;

  PersonBloc({required this.repository}) : super(PersonInitial()) {
    on<LoadPersonsEvent>(_onLoadPersons);
    on<AddPersonEvent>(_onAddPerson);
    on<UpdatePersonEvent>(_onUpdatePerson);
    on<DeletePersonEvent>(_onDeletePerson);
    on<SearchPersonsEvent>(_onSearchPersons);
  }

  Future<void> _onLoadPersons(
    LoadPersonsEvent event,
    Emitter<PersonState> emit,
  ) async {
    try {
      emit(PersonsLoading());
      final persons = await repository.getAllPersons();
      emit(PersonsLoaded(persons: persons));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  Future<void> _onAddPerson(
    AddPersonEvent event,
    Emitter<PersonState> emit,
  ) async {
    try {
      final person = await repository.addPerson(
        name: event.name,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        marriageDate: event.marriageDate,
        dateOfDeath: event.dateOfDeath,
        photoUrl: event.photoUrl,
      );
      emit(PersonAdded(person: person));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  Future<void> _onUpdatePerson(
    UpdatePersonEvent event,
    Emitter<PersonState> emit,
  ) async {
    try {
      final person = await repository.updatePerson(
        id: event.id,
        name: event.name,
        gender: event.gender,
        dateOfBirth: event.dateOfBirth,
        marriageDate: event.marriageDate,
        dateOfDeath: event.dateOfDeath,
        photoUrl: event.photoUrl,
      );
      emit(PersonUpdated(person: person));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  Future<void> _onDeletePerson(
    DeletePersonEvent event,
    Emitter<PersonState> emit,
  ) async {
    try {
      await repository.deletePerson(event.id);
      emit(PersonDeleted());
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }

  Future<void> _onSearchPersons(
    SearchPersonsEvent event,
    Emitter<PersonState> emit,
  ) async {
    try {
      emit(PersonsLoading());
      final persons = await repository.searchPersons(event.query);
      emit(PersonsLoaded(persons: persons));
    } catch (e) {
      emit(PersonsError(message: e.toString()));
    }
  }
}
