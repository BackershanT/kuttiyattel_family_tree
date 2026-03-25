import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/event_repository.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository repository;

  EventBloc({required this.repository}) : super(EventInitial()) {
    on<LoadEventsEvent>(_onLoadEvents);
    on<AddEventEvent>(_onAddEvent);
    on<DeleteEventEvent>(_onDeleteEvent);
  }

  Future<void> _onLoadEvents(LoadEventsEvent event, Emitter<EventState> emit) async {
    emit(EventsLoading());
    try {
      final dbEvents = await repository.getEvents();
      final syntheticEvents = await repository.getSyntheticEvents();
      
      // Combine and remove duplicates (if any, by ID or logic)
      final allEvents = [...dbEvents, ...syntheticEvents];
      
      emit(EventsLoaded(allEvents));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onAddEvent(AddEventEvent event, Emitter<EventState> emit) async {
    try {
      await repository.addEvent(event.event);
      add(LoadEventsEvent()); // Refresh
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onDeleteEvent(DeleteEventEvent event, Emitter<EventState> emit) async {
    try {
      await repository.deleteEvent(event.eventId);
      add(LoadEventsEvent());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
