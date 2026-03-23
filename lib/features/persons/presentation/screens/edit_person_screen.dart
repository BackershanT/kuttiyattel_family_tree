import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bloc.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/models/person_model.dart';
import '../widgets/widgets.dart';

class EditPersonScreen extends StatefulWidget {
  final String personId;

  const EditPersonScreen({
    super.key,
    required this.personId,
  });

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  late PersonBloc personBloc;
  Person? _person;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    personBloc = PersonBloc(repository: PersonRepository());
    _loadPersonData();
  }

  Future<void> _loadPersonData() async {
    setState(() {
      _isLoadingData = true;
    });

    try {
      final person = await personBloc.repository.getPersonById(widget.personId);
      setState(() {
        _person = person;
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load person data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSave(String name, String? gender, DateTime? dob, String? photoUrl) {
    if (_person == null) return;

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $name'),
            if (gender != null) Text('Gender: $gender'),
            if (dob != null) Text('DOB: ${_formatDate(dob)}'),
            if (photoUrl != null) const Text('Photo: ✓'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              personBloc.add(
                UpdatePersonEvent(
                  id: widget.personId,
                  name: name,
                  gender: gender,
                  dateOfBirth: dob,
                  photoUrl: photoUrl,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _handleDelete() {
    if (_person == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete "${_person!.name}"?'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ This will also delete all relationships (parent-child connections) associated with this person.',
              style: TextStyle(fontWeight: FontWeight.bold),
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
              personBloc.add(DeletePersonEvent(id: widget.personId));
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Delete'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: personBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Person'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isLoadingData ? null : _handleDelete,
              tooltip: 'Delete Person',
              color: Colors.red,
            ),
          ],
        ),
        body: BlocConsumer<PersonBloc, PersonState>(
          listener: (context, state) {
            if (state is PersonUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${state.person.name} updated successfully!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Navigate back
              context.go('/');
            } else if (state is PersonDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Person deleted successfully'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Navigate back
              context.go('/');
            } else if (state is PersonsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is PersonsLoading || _isLoadingData;
            final isSaving = state is PersonsLoading;

            if (isLoading && _person == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_person == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Person not found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: PersonFormWidget(
                    initialName: _person!.name,
                    initialGender: _person!.gender,
                    initialDob: _person!.dateOfBirth,
                    initialPhotoUrl: _person!.photoUrl,
                    isLoading: isSaving,
                    onSave: _handleSave,
                    onCancel: () => context.go('/'),
                  ),
                ),
                if (isSaving)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
