import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../../../persons/data/repositories/person_repository.dart';

class EventRepository {
  final _supabase = Supabase.instance.client;
  final PersonRepository _personRepository = PersonRepository();

  Future<List<EventModel>> getEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .order('event_date', ascending: true);
    
    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => EventModel.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addEvent(EventModel event) async {
    await _supabase.from('events').insert(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('events').delete().eq('id', id);
  }

  // Get synthetic events (Birthdays and Death Anniversaries from Persons table)
  Future<List<EventModel>> getSyntheticEvents() async {
    final persons = await _personRepository.getAllPersons();
    final List<EventModel> syntheticEvents = [];

    for (var person in persons) {
      if (person.dateOfBirth != null) {
        syntheticEvents.add(EventModel(
          id: 'birth-${person.id}',
          title: '${person.name}\'s Birthday',
          eventDate: person.dateOfBirth!,
          type: 'birthday',
          recurrence: 'yearly',
          personId: person.id,
          createdAt: DateTime.now(),
        ));
      }
      if (person.dateOfDeath != null) {
        syntheticEvents.add(EventModel(
          id: 'death-${person.id}',
          title: '${person.name}\'s Death Anniversary',
          eventDate: person.dateOfDeath!,
          type: 'death_anniversary',
          recurrence: 'yearly',
          personId: person.id,
          createdAt: DateTime.now(),
        ));
      }
    }
    return syntheticEvents;
  }
}
