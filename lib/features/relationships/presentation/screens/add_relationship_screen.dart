import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/relationship_repository.dart';
import '../../../persons/data/repositories/person_repository.dart';
import '../../../persons/data/models/person_model.dart';
import '../bloc/bloc.dart';
import '../widgets/person_selector_widget.dart';
import '../../../persons/presentation/widgets/date_picker_widget.dart';

class AddRelationshipScreen extends StatefulWidget {
  final String? personId; // Optional: pre-select one person

  const AddRelationshipScreen({
    super.key,
    this.personId,
  });

  @override
  State<AddRelationshipScreen> createState() => _AddRelationshipScreenState();
}

class _AddRelationshipScreenState extends State<AddRelationshipScreen> {
  late RelationshipBloc relationshipBloc;
  List<Person> _persons = [];
  String? _selectedPerson1Id;
  String? _selectedPerson2Id;
  String _selectedType = 'parent-child';
  DateTime? _weddingDate;
  bool _isLoadingPersons = true;
  bool _isAddingRelationship = false;

  final List<Map<String, String>> _relationshipTypes = [
    {'value': 'parent-child', 'label': 'Parent-Child'},
    {'value': 'spouse', 'label': 'Spouse (Husband/Wife)'},
  ];

  @override
  void initState() {
    super.initState();
    relationshipBloc = RelationshipBloc(repository: RelationshipRepository());
    _loadPersons();
    _setupBlocListener();
  }

  void _setupBlocListener() {
    relationshipBloc.stream.listen((state) {
      if (state is RelationshipAdded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Relationship added successfully!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/'); // Navigate back to home
        }
      } else if (state is RelationshipValidated) {
        if (state.isValid && _isAddingRelationship) {
          // Validation passed, proceed with adding
          _proceedAddRelationship();
        } else if (!state.isValid) {
          // Validation failed
          if (mounted) {
            setState(() {
              _isAddingRelationship = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Validation failed'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else if (state is RelationshipError) {
        if (mounted) {
          setState(() {
            _isAddingRelationship = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  Future<void> _loadPersons() async {
    try {
      final repository = PersonRepository();
      final persons = await repository.getAllPersons();
      if (mounted) {
        setState(() {
          _persons = persons;
          _isLoadingPersons = false;
          
          // Pre-select the person if provided
          if (widget.personId != null) {
            _selectedPerson1Id = widget.personId;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPersons = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load persons: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAddRelationship() {
    print('USER ACTION: Tap on "Create Relationship"');
    if (_selectedPerson1Id == null || _selectedPerson2Id == null) {
      print('⚠️ Validation failed: Both persons not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both persons'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedPerson1Id == _selectedPerson2Id) {
      print('⚠️ Validation failed: Same person selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A person cannot have a relationship with themselves'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) {
        final p1 = _persons.firstWhere((p) => p.id == _selectedPerson1Id);
        final p2 = _persons.firstWhere((p) => p.id == _selectedPerson2Id);
        final typeLabel = _relationshipTypes.firstWhere((t) => t['value'] == _selectedType)['label']!;

        return AlertDialog(
          title: const Text('Add Relationship'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create $typeLabel relationship:'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.person, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          p1.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(_selectedType == 'parent-child' ? 'Parent' : 'Partner', 
                           style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(_selectedType == 'parent-child' ? Icons.arrow_forward : Icons.sync),
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.person, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          p2.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(_selectedType == 'parent-child' ? 'Child' : 'Partner', 
                           style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ This will create a permanent family connection.',
                style: TextStyle(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                print('USER ACTION: Confirm relationship creation ($typeLabel)');
                Navigator.pop(dialogContext);
                _isAddingRelationship = true;
                // Validate first
                relationshipBloc.add(
                  ValidateRelationshipEvent(
                    parentId: _selectedPerson1Id!,
                    childId: _selectedPerson2Id!,
                    type: _selectedType,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Relationship'),
            ),
          ],
        );
      },
    );
  }

  void _proceedAddRelationship() {
    print('PROCEEDING: Sending AddRelationshipEvent to BLoC');
    if (_selectedPerson1Id == null || _selectedPerson2Id == null) return;

    relationshipBloc.add(
      AddRelationshipEvent(
        parentId: _selectedPerson1Id!,
        childId: _selectedPerson2Id!,
        type: _selectedType,
        weddingDate: _weddingDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: relationshipBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Relationship'),
          centerTitle: false,
        ),
        body: _isLoadingPersons
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info card
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.groups,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Define Family Connection',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select two people and specify their relationship.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Relationship Type selector
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Relationship Type *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: _relationshipTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Text(type['label']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Person 1 selector
                    PersonSelectorWidget(
                      selectedPersonId: _selectedPerson1Id,
                      onPersonSelected: (id) {
                        setState(() {
                          _selectedPerson1Id = id;
                        });
                      },
                      label: _selectedType == 'parent-child' ? 'Parent *' : 'Person 1 *',
                      hint: 'Search for person...',
                      availablePersons: _persons,
                      excludePersonId: _selectedPerson2Id,
                    ),
                    const SizedBox(height: 24),

                    // Person 2 selector
                    PersonSelectorWidget(
                      selectedPersonId: _selectedPerson2Id,
                      onPersonSelected: (id) {
                        setState(() {
                          _selectedPerson2Id = id;
                        });
                      },
                      label: _selectedType == 'parent-child' ? 'Child *' : 'Person 2 *',
                      hint: 'Search for person...',
                      availablePersons: _persons,
                      excludePersonId: _selectedPerson1Id,
                    ),
                    const SizedBox(height: 24),

                    if (_selectedType == 'spouse') ...[
                      DatePickerWidget(
                        label: 'Wedding Date (Optional)',
                        value: _weddingDate,
                        onChanged: (date) {
                          setState(() {
                            _weddingDate = date;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: FilledButton.icon(
                            onPressed: (_selectedPerson1Id != null &&
                                    _selectedPerson2Id != null &&
                                    !_isAddingRelationship)
                                ? _handleAddRelationship
                                : null,
                            icon: _isAddingRelationship
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.add_link),
                            label: Text(_isAddingRelationship
                                ? 'Creating...'
                                : 'Create Relationship'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
