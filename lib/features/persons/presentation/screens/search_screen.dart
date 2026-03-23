import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bloc.dart';
import '../../data/repositories/person_repository.dart';
import '../../data/models/person_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late PersonBloc personBloc;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  List<Person> _allPersons = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    personBloc = PersonBloc(repository: PersonRepository());
    personBloc.add(LoadPersonsEvent());
    _setupBlocListener();
  }

  void _setupBlocListener() {
    personBloc.stream.listen((state) {
      if (state is PersonsLoaded) {
        setState(() {
          _allPersons = state.persons;
          _isLoading = false;
        });
        // Trigger search if there's text
        if (_searchController.text.isNotEmpty) {
          _performSearch(_searchController.text);
        }
      } else if (state is PersonsError) {
        setState(() {
          _error = state.message;
          _isLoading = false;
        });
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      personBloc.add(LoadPersonsEvent());
      return;
    }
    personBloc.add(SearchPersonsEvent(query: query));
  }

  void _onSearchChanged(String value) {
    // Cancel previous timer
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Start new debounce timer (300ms)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(value);
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    personBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search persons...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
        ),
        centerTitle: false,
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
                        'Failed to load data',
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
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          personBloc.add(LoadPersonsEvent());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : BlocBuilder<PersonBloc, PersonState>(
                  builder: (context, state) {
                    final persons = state is PersonsLoaded ? state.persons : [];

                    if (persons.isEmpty && _searchController.text.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No results found for "${_searchController.text}"',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    if (persons.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No persons found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start by adding a new person',
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
                        itemCount: persons.length,
                        itemBuilder: (context, index) {
                          final person = persons[index];
                          return Card(
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
                                                  placeholder:
                                                      (context, url) =>
                                                          const Padding(
                                                    padding: EdgeInsets.all(12),
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
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
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
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
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
