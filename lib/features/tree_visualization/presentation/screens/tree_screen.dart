import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc.dart';
import '../../data/repositories/tree_repository.dart';
import '../widgets/tree_graph_widget.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

class _TreeScreenState extends State<TreeScreen> {
  late TreeBloc treeBloc;

  @override
  void initState() {
    super.initState();
    treeBloc = TreeBloc(repository: TreeRepository());
    treeBloc.add(LoadTreeDataEvent());
  }

  @override
  void dispose() {
    treeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: treeBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Family Tree'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                treeBloc.add(RefreshTreeEvent());
              },
              tooltip: 'Refresh Tree',
            ),
            IconButton(
              icon: const Icon(Icons.fit_screen),
              onPressed: () {
                // Reset zoom could be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pinch to zoom in/out')),
                );
              },
              tooltip: 'Fit to Screen',
            ),
          ],
        ),
        body: Column(
          children: [
            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pinch to zoom • Drag to pan • Tap person for details',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            // Tree graph
            const Expanded(
              child: TreeGraphWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
