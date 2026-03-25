import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../events/presentation/bloc/event_bloc.dart';
import '../../../events/presentation/bloc/event_event.dart';
import '../../../events/presentation/bloc/event_state.dart';
import '../../../events/data/repositories/event_repository.dart';
import '../../../events/presentation/widgets/add_event_dialog.dart';
import '../../../events/data/models/event_model.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({super.key});

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late EventBloc _eventBloc;

  @override
  void initState() {
    super.initState();
    _eventBloc = EventBloc(repository: EventRepository());
    _eventBloc.add(LoadEventsEvent());
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _eventBloc.close();
    super.dispose();
  }

  List<EventModel> _getEventsForDay(DateTime day, List<EventModel> allEvents) {
    return allEvents.where((event) {
      final eDate = event.eventDate;
      if (event.recurrence == 'none') {
        return isSameDay(eDate, day);
      } else if (event.recurrence == 'monthly') {
        return eDate.day == day.day;
      } else if (event.recurrence == 'yearly') {
        return eDate.month == day.month && eDate.day == day.day;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _eventBloc,
      child: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          List<EventModel> allEvents = [];
          if (state is EventsLoaded) {
            allEvents = state.events;
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final event = await showDialog<EventModel>(
                  context: context,
                  builder: (context) => AddEventDialog(initialDate: _selectedDay),
                );
                if (event != null) {
                  _eventBloc.add(AddEventEvent(event));
                }
              },
              mini: true,
              child: const Icon(Icons.add),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.utc(1900, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      eventLoader: (day) => _getEventsForDay(day, allEvents),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                if (state is EventsLoading)
                  const Center(child: CircularProgressIndicator())
                else if (state is EventError)
                  Center(child: Text('Error: ${state.message}'))
                else
                  Expanded(
                    child: _selectedDay == null
                        ? const Center(child: Text('Select a day to see events'))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('MMMM d, yyyy').format(_selectedDay!),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: _getEventsForDay(_selectedDay!, allEvents).isEmpty
                                      ? const Center(child: Text('No events for this day'))
                                      : ListView.builder(
                                          itemCount: _getEventsForDay(_selectedDay!, allEvents).length,
                                          itemBuilder: (context, index) {
                                            final event = _getEventsForDay(_selectedDay!, allEvents)[index];
                                            return Card(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 0,
                                              color: Colors.white,
                                              child: ListTile(
                                                leading: Icon(
                                                  event.type == 'birthday' ? Icons.cake : 
                                                  event.type == 'wedding_anniversary' ? Icons.favorite :
                                                  Icons.event,
                                                  color: Colors.deepOrangeAccent,
                                                ),
                                                title: Text(event.title),
                                                subtitle: Text(event.recurrence == 'yearly' ? 'Every Year' : 
                                                              event.recurrence == 'monthly' ? 'Every Month' : 
                                                              'One-time Event'),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
