import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/person_model.dart';
import '../../data/repositories/person_repository.dart';
import '../../../relationships/data/repositories/relationship_repository.dart';
import '../../../relationships/data/models/relationship_model.dart';
import '../../../relationships/presentation/widgets/relationship_list_widget.dart';

class PersonDetailsScreen extends StatefulWidget {
  final String personId;

  const PersonDetailsScreen({
    super.key,
    required this.personId,
  });

  @override
  State<PersonDetailsScreen> createState() => _PersonDetailsScreenState();
}

class _PersonDetailsScreenState extends State<PersonDetailsScreen> {
  Person? _person;
  bool _isLoading = true;
  String? _error;
  List<Relationship> _relationships = [];
  List<Person> _allPersons = [];
  bool _isLoadingRelationships = false;

  @override
  void initState() {
    super.initState();
    _loadPersonData();
    _loadRelationships();
  }

  Future<void> _loadPersonData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = PersonRepository();
      final person = await repository.getPersonById(widget.personId);
      setState(() {
        _person = person;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadRelationships() async {
    setState(() {
      _isLoadingRelationships = true;
    });

    try {
      final relationshipRepo = RelationshipRepository();
      final personRepo = PersonRepository();
      
      // Load relationships for this person
      final asParent = await relationshipRepo.getRelationshipsByParentId(widget.personId);
      final asChild = await relationshipRepo.getRelationshipsByChildId(widget.personId);
      
      setState(() {
        _relationships = [...asParent, ...asChild];
        _isLoadingRelationships = false;
      });

      // Load all persons to display in relationship lists
      try {
        final allPersons = await personRepo.getAllPersons();
        setState(() {
          _allPersons = allPersons;
        });
      } catch (e) {
        // Silently fail - relationships will still show without full person data
      }
    } catch (e) {
      setState(() {
        _isLoadingRelationships = false;
      });
    }
  }

  void _handleDeleteRelationship(String relationshipId) async {
    try {
      final repository = RelationshipRepository();
      await repository.deleteRelationship(relationshipId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relationship removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRelationships(); // Reload relationships
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove relationship: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
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
              '⚠️ This action cannot be undone and will delete all relationships.',
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
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final repository = PersonRepository();
                await repository.deletePerson(widget.personId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Person deleted successfully'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  context.go('/');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
    if (date == null) return 'Not specified';
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/edit-person/$widget.personId'),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _isLoading ? null : _showDeleteConfirmation,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load person details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _loadPersonData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _person == null
                  ? Center(
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
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPersonData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Profile Photo Card
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getGenderColor(_person!.gender),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    // Profile Photo
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundColor: Colors.white,
                                      child: _person!.photoUrl != null
                                          ? ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: _person!.photoUrl!,
                                                width: 120,
                                                height: 120,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Padding(
                                                  padding: EdgeInsets.all(16),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(
                                                  _getGenderIcon(
                                                      _person!.gender),
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              _getGenderIcon(_person!.gender),
                                              size: 60,
                                              color: Colors.grey.shade600,
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Name
                                    Text(
                                      _person!.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    // Gender Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getGenderColor(_person!.gender)
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getGenderColor(
                                                  _person!.gender)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getGenderIcon(_person!.gender),
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _person!.gender ?? 'Not specified',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Information Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Personal Information',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const Divider(height: 24),
                                    _buildInfoRow(
                                      icon: Icons.cake,
                                      label: 'Date of Birth',
                                      value: _formatDate(_person!.dateOfBirth),
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      icon: Icons.access_time,
                                      label: 'Added On',
                                      value: _formatDate(_person!.createdAt),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Actions Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.edit),
                                      title: const Text('Edit Profile'),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => context
                                          .push('/edit-person/${_person!.id}'),
                                    ),
                                    const Divider(height: 1),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      title: const Text(
                                        'Delete Profile',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      trailing: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.red,
                                      ),
                                      onTap: _showDeleteConfirmation,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Relationships Section
                            if (_isLoadingRelationships)
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              )
                            else ...[
                              // Parents (people who are parents of this person)
                              RelationshipListWidget(
                                relationships: _relationships,
                                allPersons: _allPersons,
                                personId: _person!.id,
                                showAsParent: false, // Show as child
                                onAddTap: () {
                                  context.push('/add-relationship?personId=${_person!.id}&role=parent');
                                },
                                onDeleteTap: _handleDeleteRelationship,
                              ),
                              const SizedBox(height: 16),

                              // Children (people who are children of this person)
                              RelationshipListWidget(
                                relationships: _relationships,
                                allPersons: _allPersons,
                                personId: _person!.id,
                                showAsParent: true, // Show as parent
                                onAddTap: () {
                                  context.push('/add-relationship?personId=${_person!.id}&role=child');
                                },
                                onDeleteTap: _handleDeleteRelationship,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
