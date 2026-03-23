import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../persons/data/models/person_model.dart';

/// Searchable person selector widget for choosing a person in relationship forms
class PersonSelectorWidget extends StatefulWidget {
  final String? selectedPersonId;
  final ValueChanged<String?> onPersonSelected;
  final String label;
  final String? hint;
  final List<Person> availablePersons;
  final String? excludePersonId; // Don't select this person

  const PersonSelectorWidget({
    super.key,
    this.selectedPersonId,
    required this.onPersonSelected,
    required this.label,
    this.hint,
    required this.availablePersons,
    this.excludePersonId,
  });

  @override
  State<PersonSelectorWidget> createState() => _PersonSelectorWidgetState();
}

class _PersonSelectorWidgetState extends State<PersonSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Person> _filteredPersons = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredPersons = widget.availablePersons;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPersons(String query) {
    setState(() {
      _isSearching = true;
      if (query.isEmpty) {
        _filteredPersons = widget.availablePersons;
      } else {
        _filteredPersons = widget.availablePersons.where((person) {
          return person.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
      _isSearching = false;
    });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Search person...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _filterPersons('');
                    },
                  )
                : null,
          ),
          onChanged: _filterPersons,
        ),
        const SizedBox(height: 12),
        // Selected person display
        if (widget.selectedPersonId != null) ...[
          _buildSelectedPersonCard(),
          const SizedBox(height: 12),
        ],
        // Person list
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _filteredPersons.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No persons found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredPersons.length,
                      itemBuilder: (context, index) {
                        final person = _filteredPersons[index];
                        
                        // Skip if this is the excluded person
                        if (person.id == widget.excludePersonId) {
                          return const SizedBox.shrink();
                        }

                        final isSelected = person.id == widget.selectedPersonId;

                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: _getGenderColor(person.gender),
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
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : null,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getGenderColor(person.gender)
                                      .withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  person.gender ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall,
                                ),
                              ),
                              if (person.dateOfBirth != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• ${_formatDate(person.dateOfBirth)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                          onTap: () {
                            widget.onPersonSelected(person.id);
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSelectedPersonCard() {
    final selectedPerson = widget.availablePersons.firstWhere(
      (p) => p.id == widget.selectedPersonId,
      orElse: () => throw Exception('Person not found'),
    );

    return Card(
      color: _getGenderColor(selectedPerson.gender),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: selectedPerson.photoUrl != null
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: selectedPerson.photoUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(_getGenderIcon(selectedPerson.gender)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedPerson.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    selectedPerson.gender ?? '',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => widget.onPersonSelected(null),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
