class EventModel {
  final String id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String type; // 'birthday', 'death_anniversary', 'wedding_anniversary', 'other'
  final String recurrence; // 'none', 'monthly', 'yearly'
  final String? personId;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.eventDate,
    required this.type,
    this.recurrence = 'none',
    this.personId,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      eventDate: DateTime.parse(map['event_date'] as String),
      type: map['type'] as String? ?? 'other',
      recurrence: map['recurrence'] as String? ?? 'none',
      personId: map['person_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String().split('T')[0], // YYYY-MM-DD
      'type': type,
      'recurrence': recurrence,
      'person_id': personId,
    };
  }

  EventModel copyWith({
    String? title,
    String? description,
    DateTime? eventDate,
    String? type,
    String? recurrence,
    String? personId,
  }) {
    return EventModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      type: type ?? this.type,
      recurrence: recurrence ?? this.recurrence,
      personId: personId ?? this.personId,
      createdAt: createdAt,
    );
  }
}
