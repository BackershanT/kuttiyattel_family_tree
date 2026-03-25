import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/tree_visualization/presentation/screens/tree_screen.dart';
import '../../features/persons/presentation/screens/person_list_screen.dart';
import '../../features/persons/presentation/screens/add_person_screen.dart';
import '../../features/persons/presentation/screens/edit_person_screen.dart';
import '../../features/persons/presentation/screens/search_screen.dart';
import '../../features/persons/presentation/screens/person_details_screen.dart';
import '../../features/relationships/presentation/screens/add_relationship_screen.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const TreeScreen(),
      routes: [
        GoRoute(
          path: 'familymembers',
          name: 'family-members',
          builder: (context, state) => const PersonListScreen(),
        ),
        GoRoute(
          path: 'add-person',
          name: 'add-person',
          builder: (context, state) => const AddPersonScreen(),
        ),
        GoRoute(
          path: 'search',
          name: 'search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: 'edit-person/:id',
          name: 'edit-person',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return EditPersonScreen(personId: id);
          },
        ),
        GoRoute(
          path: 'person-details/:id',
          name: 'person-details',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return PersonDetailsScreen(personId: id);
          },
        ),
        GoRoute(
          path: 'add-relationship',
          name: 'add-relationship',
          builder: (context, state) {
            final personId = state.uri.queryParameters['personId'];
            return AddRelationshipScreen(personId: personId);
          },
        ),
      ],
    ),
  ],
);
