import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/event_model.dart';
import '../../../persons/data/models/person_model.dart';
import '../../../persons/data/repositories/person_repository.dart';

class AddEventDialog extends StatefulWidget {
  final DateTime? initialDate;
  const AddEventDialog({super.key, this.initialDate});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'other';
  String _selectedRecurrence = 'none';
  String? _selectedPersonId;
  List<Person> _persons = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) _selectedDate = widget.initialDate!;
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    final repo = PersonRepository();
    final persons = await repo.getAllPersons();
    setState(() => _persons = persons);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Family Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Event Type'),
                items: const [
                  DropdownMenuItem(value: 'birthday', child: Text('Birthday')),
                  DropdownMenuItem(value: 'death_anniversary', child: Text('Death Anniversary')),
                  DropdownMenuItem(value: 'wedding_anniversary', child: Text('Wedding Anniversary')),
                  DropdownMenuItem(value: 'other', child: Text('Other Event')),
                ],
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) setState(() => _selectedDate = date);
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRecurrence,
                decoration: const InputDecoration(labelText: 'Recurrence'),
                items: const [
                  DropdownMenuItem(value: 'none', child: Text('This year only')),
                  DropdownMenuItem(value: 'monthly', child: Text('Every month')),
                  DropdownMenuItem(value: 'yearly', child: Text('Every year')),
                ],
                onChanged: (v) => setState(() => _selectedRecurrence = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _selectedPersonId,
                decoration: const InputDecoration(labelText: 'Related Person (Optional)'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ..._persons.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))),
                ],
                onChanged: (v) => setState(() => _selectedPersonId = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final event = EventModel(
                id: const Uuid().v4(),
                title: _titleController.text,
                description: _descController.text,
                eventDate: _selectedDate,
                type: _selectedType,
                recurrence: _selectedRecurrence,
                personId: _selectedPersonId,
                createdAt: DateTime.now(),
              );
              Navigator.pop(context, event);
            }
          },
          child: const Text('Save Event'),
        ),
      ],
    );
  }
}
