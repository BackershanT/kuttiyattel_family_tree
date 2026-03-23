import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/relationship_model.dart';
import '../../../persons/data/models/person_model.dart';

/// Widget to display a list of relationships (parents or children)
class RelationshipListWidget extends StatelessWidget {
  final List<Relationship> relationships;
  final List<Person> allPersons;
  final String personId;
  final bool showAsParent; // true = show children, false = show parents
  final VoidCallback? onAddTap;
  final Function(String relationshipId)? onDeleteTap;

  const RelationshipListWidget({
    super.key,
    required this.relationships,
    required this.allPersons,
    required this.personId,
    required this.showAsParent,
    this.onAddTap,
    this.onDeleteTap,
  });

  List<Person> _getRelatedPersons() {
    if (showAsParent) {
      // This person is a parent, show their children
      return relationships
          .where((r) => r.parentId == personId)
          .map((r) {
            try {
              return allPersons.firstWhere((p) => p.id == r.childId);
            } catch (e) {
              return null;
            }
          })
          .whereType<Person>()
          .toList();
    } else {
      // This person is a child, show their parents
      return relationships
          .where((r) => r.childId == personId)
          .map((r) {
            try {
              return allPersons.firstWhere((p) => p.id == r.parentId);
            } catch (e) {
              return null;
            }
          })
          .whereType<Person>()
          .toList();
    }
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

  @override
  Widget build(BuildContext context) {
    final relatedPersons = _getRelatedPersons();

    if (relatedPersons.isEmpty && onAddTap == null) {
      return const SizedBox.shrink(); // Don't show if empty and can't add
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  showAsParent ? Icons.child_care : Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  showAsParent ? 'Children' : 'Parents',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                if (onAddTap != null)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: onAddTap,
                    tooltip: showAsParent ? 'Add child' : 'Add parent',
                    iconSize: 20,
                  ),
              ],
            ),
            const Divider(height: 24),
            relatedPersons.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      showAsParent
                          ? 'No children yet. Tap + to add.'
                          : 'No parents recorded.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: relatedPersons.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final person = relatedPersons[index];
                      
                      // Find relationship ID for deletion
                      final relationship = relationships.firstWhere(
                        (r) => showAsParent
                            ? r.parentId == personId && r.childId == person.id
                            : r.childId == personId && r.parentId == person.id,
                      );

                      return Dismissible(
                        key: Key(relationship.id),
                        direction: onDeleteTap != null
                            ? DismissDirection.endToStart
                            : DismissDirection.none,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.link_off,
                            color: Colors.red.shade700,
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (onDeleteTap != null) {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Remove Relationship'),
                                content: Text(
                                  'Remove the relationship between this person and ${person.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton.icon(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    icon: const Icon(Icons.link_off),
                                    label: const Text('Remove'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            );
                            return confirmed ?? false;
                          }
                          return false;
                        },
                        onDismissed: (_) {
                          if (onDeleteTap != null) {
                            onDeleteTap!(relationship.id);
                          }
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: person.photoUrl != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: person.photoUrl!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
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
                          title: Text(
                            person.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            person.gender ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () =>
                                context.push('/person-details/${person.id}'),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
