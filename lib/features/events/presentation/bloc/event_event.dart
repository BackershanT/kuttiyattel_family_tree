import 'package:equatable/equatable.dart';
import '../../data/models/event_model.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();
  @override
  List<Object?> get props => [];
}

class LoadEventsEvent extends EventEvent {}

class AddEventEvent extends EventEvent {
  final EventModel event;
  const AddEventEvent(this.event);
  @override
  List<Object?> get props => [event];
}

class DeleteEventEvent extends EventEvent {
  final String eventId;
  const DeleteEventEvent(this.eventId);
  @override
  List<Object?> get props => [eventId];
}
