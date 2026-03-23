import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bloc.dart';
import '../../data/repositories/person_repository.dart';
import '../widgets/widgets.dart';

class AddPersonScreen extends StatelessWidget {
  const AddPersonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PersonBloc(repository: PersonRepository()),
      child: const _AddPersonContent(),
    );
  }
}

class _AddPersonContent extends StatelessWidget {
  const _AddPersonContent();

  void _handleSave({
    required BuildContext context,
    required String name,
    required String? gender,
    required DateTime? dob,
    required String? photoUrl,
  }) {
    final personBloc = context.read<PersonBloc>();
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Person'),
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
              // Print statement when Add Person button is tapped in popup
              print('═══════════════════════════════════════════════════════════');
              print('ADD PERSON BUTTON TAPPED IN CONFIRMATION DIALOG');
              print('═══════════════════════════════════════════════════════════');
              print('Name: $name');
              print('Gender: ${gender ?? "Not specified"}');
              print('Date of Birth: ${dob != null ? _formatDate(dob) : "Not specified"}');
              print('Photo URL: ${photoUrl ?? "No photo"}');
              print('Timestamp: ${DateTime.now().toString()}');
              print('Submitting to database...');
              print('═══════════════════════════════════════════════════════════');
              
              Navigator.pop(dialogContext);
              personBloc.add(
                AddPersonEvent(
                  name: name,
                  gender: gender,
                  dateOfBirth: dob,
                  photoUrl: photoUrl,
                ),
              );
            },
            child: const Text('Add Person'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Person'),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: BlocConsumer<PersonBloc, PersonState>(
        listener: (context, state) {
          if (state is PersonAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.person.name} added successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate back to home
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
          final isLoading = state is PersonsLoading;
          
          // Show loading overlay
          if (isLoading) {
            return Stack(
              children: [
                _buildForm(context),
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            );
          }
          
          return _buildForm(context);
        },
      ),
    );
  }
  
  Widget _buildForm(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: PersonFormWidget(
                  isLoading: false,
                  onSave: (name, gender, dob, photoUrl) {
                    _handleSave(
                      context: context,
                      name: name,
                      gender: gender,
                      dob: dob,
                      photoUrl: photoUrl,
                    );
                  },
                  onCancel: () {
                    context.go('/');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
