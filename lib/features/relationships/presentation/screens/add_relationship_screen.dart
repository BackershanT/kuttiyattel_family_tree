import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/relationship_repository.dart';
import '../../../persons/data/repositories/person_repository.dart';
import '../../../persons/data/models/person_model.dart';
import '../bloc/bloc.dart';
import '../widgets/person_selector_widget.dart';

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
  String? _selectedParentId;
  String? _selectedChildId;
  bool _isLoadingPersons = true;
  bool _isAddingRelationship = false;

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Relationship added successfully!',
              
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/'); // Navigate back to home
      } else if (state is RelationshipValidated) {
        if (state.isValid && _isAddingRelationship) {
          // Validation passed, proceed with adding
          _proceedAddRelationship();
        } else if (!state.isValid) {
          // Validation failed
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
      } else if (state is RelationshipError) {
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
    });
  }

  Future<void> _loadPersons() async {
    try {
      final repository = PersonRepository();
      final persons = await repository.getAllPersons();
      setState(() {
        _persons = persons;
        _isLoadingPersons = false;
        
        // Pre-select the person if provided
        if (widget.personId != null) {
          _selectedParentId = widget.personId;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingPersons = false;
      });
      if (mounted) {
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
    if (_selectedParentId == null || _selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both parent and child'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedParentId == _selectedChildId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A person cannot be their own parent'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) {
        final parent = _persons.firstWhere((p) => p.id == _selectedParentId);
        final child = _persons.firstWhere((p) => p.id == _selectedChildId);

        return AlertDialog(
          title: const Text('Add Relationship'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create parent-child relationship:'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          parent.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Parent', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_downward),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.person, size: 32),
                        const SizedBox(height: 4),
                        Text(
                          child.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text('Child', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ This will create a permanent family connection.',
                style: TextStyle(fontStyle: FontStyle.italic),
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
                Navigator.pop(dialogContext);
                // Validate first
                relationshipBloc.add(
                  ValidateRelationshipEvent(
                    parentId: _selectedParentId!,
                    childId: _selectedChildId!,
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
    if (_selectedParentId == null || _selectedChildId == null) return;

    setState(() {
      _isAddingRelationship = true;
    });

    relationshipBloc.add(
      AddRelationshipEvent(
        parentId: _selectedParentId!,
        childId: _selectedChildId!,
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
                              'Select a parent and a child to create a family relationship.',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Parent selector
                    PersonSelectorWidget(
                      selectedPersonId: _selectedParentId,
                      onPersonSelected: (id) {
                        setState(() {
                          _selectedParentId = id;
                        });
                      },
                      label: 'Parent *',
                      hint: 'Search for parent...',
                      availablePersons: _persons,
                      excludePersonId: _selectedChildId,
                    ),
                    const SizedBox(height: 24),

                    // Child selector
                    PersonSelectorWidget(
                      selectedPersonId: _selectedChildId,
                      onPersonSelected: (id) {
                        setState(() {
                          _selectedChildId = id;
                        });
                      },
                      label: 'Child *',
                      hint: 'Search for child...',
                      availablePersons: _persons,
                      excludePersonId: _selectedParentId,
                    ),
                    const SizedBox(height: 32),

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
                            onPressed: (_selectedParentId != null &&
                                    _selectedChildId != null &&
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
