import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bloc.dart';
import '../../data/repositories/tree_repository.dart';
import '../widgets/tree_graph_widget.dart';
import '../widgets/memories_tab.dart';
import '../widgets/events_tab.dart';
import '../../../../core/router/routes.dart';

class TreeScreen extends StatefulWidget {
  const TreeScreen({super.key});

  @override
  State<TreeScreen> createState() => _TreeScreenState();
}

enum TreeTab { family, memories, events }

class _TreeScreenState extends State<TreeScreen> {
  late TreeBloc treeBloc;
  TreeTab _currentTab = TreeTab.family;
  double _currentZoom = 1.0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    treeBloc = TreeBloc(repository: TreeRepository());
    treeBloc.add(LoadTreeDataEvent());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    treeBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Defensive zoom calculation
    final double zoom = _currentZoom;
    final int zoomPercent = (((zoom.isFinite && !zoom.isNaN) ? zoom : 1.0) * 100).toInt();
    
    return BlocProvider.value(
      value: treeBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), 
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    const SizedBox(height: 120),
                    Expanded(
                      child: _buildBody(),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildNavTab(TreeTab.family, theme),
                            _buildNavTab(TreeTab.memories, theme),
                            _buildNavTab(TreeTab.events, theme),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_currentTab == TreeTab.family)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.list_alt_rounded, color: Colors.grey),
                                onPressed: () {
                                  context.pushNamed('family-members');
                                },
                                tooltip: 'Family Members List',
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 300,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    const Icon(Icons.search, size: 20, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        decoration: const InputDecoration(
                                          hintText: 'Search Members',
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                    const SizedBox(width: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '$zoomPercent%',
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const Icon(Icons.keyboard_arrow_down),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_currentTab == TreeTab.family) ...[
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildControlButton(Icons.remove),
                          const SizedBox(width: 8),
                          const CircleAvatar(
                            radius: 16,
                            child: Icon(Icons.person, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Zoom $zoomPercent%',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          _buildControlButton(Icons.add),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  right: 24,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      context.pushNamed(AppRoutes.addRelationship);
                    },
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Relative'),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case TreeTab.family:
        return TreeGraphWidget(
          searchQuery: _searchController.text,
          onScaleChanged: (scale) {
            if (mounted) {
              setState(() {
                _currentZoom = scale;
              });
            }
          },
        );
      case TreeTab.memories:
        return const MemoriesTab();
      case TreeTab.events:
        return const EventsTab();
    }
  }

  Widget _buildNavTab(TreeTab tab, ThemeData theme) {
    String label = '';
    IconData icon = Icons.help;
    switch (tab) {
      case TreeTab.family:
        label = 'Family';
        icon = Icons.people;
        break;
      case TreeTab.memories:
        label = 'Memories';
        icon = Icons.collections;
        break;
      case TreeTab.events:
        label = 'Events';
        icon = Icons.event;
        break;
    }

    final isActive = _currentTab == tab;

    return GestureDetector(
      onTap: () => setState(() => _currentTab = tab),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: isActive ? theme.colorScheme.primary : Colors.grey),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
            if (isActive)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 20,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            if (!isActive)
              const SizedBox(height: 6), 
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: Colors.black54),
    );
  }
}
