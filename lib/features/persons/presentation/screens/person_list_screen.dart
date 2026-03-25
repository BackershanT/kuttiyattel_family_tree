import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/bloc.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/models/person_model.dart';
import '../../../../core/router/routes.dart';

class PersonListScreen extends StatefulWidget {
  const PersonListScreen({super.key});

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  late PersonBloc personBloc;
  String _sortBy = 'name'; // name, dob, createdAt
  String? _filterGender; // null = all genders
  bool _showFilterDialog = false;

  @override
  void initState() {
    super.initState();
    personBloc = PersonBloc(repository: PersonRepository());
    personBloc.add(LoadPersonsEvent());
  }

  @override
  void dispose() {
    personBloc.close();
    super.dispose();
  }

  List<Person> _sortAndFilterPersons(List<Person> persons) {
    var result = List<Person>.from(persons);

    // Filter by gender
    if (_filterGender != null) {
      result = result.where((p) => p.gender == _filterGender).toList();
    }

    // Sort
    result.sort((a, b) {
      switch (_sortBy) {
        case 'dob':
          if (a.dateOfBirth == null && b.dateOfBirth == null) return 0;
          if (a.dateOfBirth == null) return 1;
          if (b.dateOfBirth == null) return -1;
          return b.dateOfBirth!.compareTo(a.dateOfBirth!); // Newest first
        case 'createdAt':
          if (a.createdAt == null && b.createdAt == null) return 0;
          if (a.createdAt == null) return 1;
          if (b.createdAt == null) return -1;
          return b.createdAt!.compareTo(a.createdAt!); // Newest first
        case 'name':
        default:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
    });

    return result;
  }

  void _showSortFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Sort & Filter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sort Section
                Text(
                  'Sort By',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String>(
                  title: const Text('Name (A-Z)'),
                  value: 'name',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setDialogState(() {
                      _sortBy = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Date of Birth'),
                  value: 'dob',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setDialogState(() {
                      _sortBy = value!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Recently Added'),
                  value: 'createdAt',
                  groupValue: _sortBy,
                  onChanged: (value) {
                    setDialogState(() {
                      _sortBy = value!;
                    });
                  },
                ),
                const Divider(height: 24),
                // Filter Section
                Text(
                  'Filter by Gender',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                RadioListTile<String?>(
                  title: const Text('All'),
                  value: null,
                  groupValue: _filterGender,
                  onChanged: (value) {
                    setDialogState(() {
                      _filterGender = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: const Text('Male'),
                  value: 'Male',
                  groupValue: _filterGender,
                  onChanged: (value) {
                    setDialogState(() {
                      _filterGender = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: const Text('Female'),
                  value: 'Female',
                  groupValue: _filterGender,
                  onChanged: (value) {
                    setDialogState(() {
                      _filterGender = value;
                    });
                  },
                ),
                RadioListTile<String?>(
                  title: const Text('Other'),
                  value: 'Other',
                  groupValue: _filterGender,
                  onChanged: (value) {
                    setDialogState(() {
                      _filterGender = value;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _sortBy = 'name';
                  _filterGender = null;
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(dialogContext);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Person person) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Person'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete "${person.name}"?'),
            const SizedBox(height: 16),
            const Text(
              '⚠️ This will also delete all relationships.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
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
              personBloc.add(DeletePersonEvent(id: person.id));
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

  Color _getGenderColor(String? gender) {
    switch (gender) {
      case 'Male':
        return Colors.blue.shade50;
      case 'Female':
        return Colors.pink.shade50;
      default:
        return Colors.purple.shade50;
    }
  }

  IconData _getGenderIcon(String? gender) {
    switch (gender) {
      case 'Male':
        return Icons.male;
      case 'Female':
        return Icons.female;
      default:
        return Icons.person_outline;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: personBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Family Members'),
          actions: [
            if (_filterGender != null || _sortBy != 'name')
              IconButton(
                icon: Badge(
                  child: const Icon(Icons.filter_alt),
                ),
                onPressed: _showSortFilterDialog,
                tooltip: 'Sort & Filter (Active)',
              )
            else
              IconButton(
                icon: const Icon(Icons.filter_alt),
                onPressed: _showSortFilterDialog,
                tooltip: 'Sort & Filter',
              ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.go('/search'),
              tooltip: 'Search',
            ),
            IconButton(
              icon: const Icon(Icons.account_tree),
              onPressed: () => context.go(AppRoutes.tree),
              tooltip: 'Family Tree',
            ),
          ],
        ),
        body: BlocConsumer<PersonBloc, PersonState>(
          listener: (context, state) {
            if (state is PersonDeleted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Person deleted successfully'),
                  backgroundColor: Colors.orange,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // Reload the list
              personBloc.add(LoadPersonsEvent());
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
            if (state is PersonsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is PersonsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        personBloc.add(LoadPersonsEvent());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is PersonsLoaded) {
              // Debug print
              print('═══════════════════════════════════════════════════════');
              print('PERSONS LOADED: ${state.persons.length} persons');
              for (var person in state.persons) {
                print('  - ${person.name} (${person.gender}) - DOB: ${person.dateOfBirth}');
              }
              print('═══════════════════════════════════════════════════════');
              
              if (state.persons.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No family members yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first family member',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  personBloc.add(LoadPersonsEvent());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sortAndFilterPersons(state.persons).length,
                  itemBuilder: (context, index) {
                    final person = _sortAndFilterPersons(state.persons)[index];
                    return Dismissible(
                      key: Key(person.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade700,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        _showDeleteConfirmation(person);
                        return false; // We handle deletion manually
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () =>
                              context.push('/person-details/${person.id}'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getGenderColor(person.gender),
                                  Colors.white,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Avatar/Photo
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: person.photoUrl != null
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: person.photoUrl!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  const Padding(
                                                padding: EdgeInsets.all(12),
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              ),
                                              errorWidget: (context, url, error) =>
                                                  Icon(
                                                _getGenderIcon(person.gender),
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            _getGenderIcon(person.gender),
                                            color: Colors.grey.shade600,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          person.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: _getGenderColor(
                                                        person.gender)
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    _getGenderIcon(
                                                        person.gender),
                                                    size: 12,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    person.gender ?? '',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (person.dateOfBirth != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                '• ${_formatDate(person.dateOfBirth)}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const Center(child: Text('No data available'));
          },
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Add Relationship FAB
            FloatingActionButton.extended(
              heroTag: 'addRelationshipFab',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Add Relationship...'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.push('/add-relationship');
              },
              icon: const Icon(Icons.groups),
              label: const Text('Add Relationship'),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 8),
            // Add Person FAB
            FloatingActionButton.extended(
              heroTag: 'addPersonFab',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigating to Add Person...'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.go('/add-person');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Person'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
