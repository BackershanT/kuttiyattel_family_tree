import 'package:flutter/material.dart';
import 'package:graphview/graphview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bloc.dart';
import '../../data/models/tree_node_data.dart';
import '../widgets/widgets.dart';
import '../../../../core/router/routes.dart';

class TreeGraphWidget extends StatefulWidget {
  final ValueChanged<double>? onScaleChanged;
  final String searchQuery;

  const TreeGraphWidget({
    super.key,
    this.onScaleChanged,
    this.searchQuery = '',
  });

  @override
  State<TreeGraphWidget> createState() => _TreeGraphWidgetState();
}

class _TreeGraphWidgetState extends State<TreeGraphWidget> {
  late Graph graph;
  late Map<String, Node> nodeMap;

  @override
  void initState() {
    super.initState();
    graph = Graph();
    nodeMap = {};
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale.isFinite && !scale.isNaN) {
      widget.onScaleChanged?.call(scale);
    }
  }

  void _buildGraph(TreeLoaded state) {
    graph = Graph();
    nodeMap = {};

    // Build nodes and edges recursively
    _addNodeAndChildren(state.root);

    // Defer setState until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _addNodeAndChildren(TreeNodeData node) {
    // Create node if not exists
    if (!nodeMap.containsKey(node.person.id)) {
      // Use Node.Id constructor which should work across platforms
      final graphNode = Node.Id(node.person.id);
      nodeMap[node.person.id] = graphNode;
      graph.addNode(graphNode);
      
      // Debug logging for first few nodes
      if (graph.nodes.length <= 3) {
        final keyValue = graphNode.key?.value != null 
            ? graphNode.key!.value!.toString()
            : 'key or key.value is NULL';
        print('  Added node: ID=${node.person.id}, Name=${node.person.name}, GraphNode key=$keyValue');
      }
    }

    // Add children and edges
    for (final child in node.children) {
      if (!nodeMap.containsKey(child.person.id)) {
        final childNode = Node.Id(child.person.id);
        nodeMap[child.person.id] = childNode;
        graph.addNode(childNode);
        
        // Debug logging for first few children
        if (graph.nodes.length <= 5) {
          final keyValue = childNode.key?.value != null 
              ? childNode.key!.value!.toString()
              : 'key or key.value is NULL';
          print('  Added child: ID=${child.person.id}, Name=${child.person.name}, GraphNode key=$keyValue');
        }
      }

      // Add edge from parent to child - with null safety
      final parentNode = nodeMap[node.person.id];
      final childNode = nodeMap[child.person.id];
      
      if (parentNode != null && childNode != null) {
        graph.addEdge(parentNode, childNode);
      } else {
        print('ERROR: Cannot add edge - parent or child node is null');
      }
      
      // Recursively add grandchildren
      _addNodeAndChildren(child);
    }
  }

  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _centerRootNode() {
    if (nodeMap.containsKey('virtual_root')) {
      // Small delay to ensure layout is complete
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        
        // Reset transformation to top-left of the content
        _transformationController.value = Matrix4.identity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TreeBloc, TreeState>(
      listener: (context, state) {
        if (state is TreeLoaded) {
          // Only build graph if it's the first time or if data changed
          // We can't easily check data change here without deep compare, 
          // but Bloc should handle emitting only on true changes.
          print('TREE STATE UPDATED: Rebuilding graph in listener...');
          _buildGraph(state);
          _centerRootNode();
        }
      },
      builder: (context, state) {
        if (state is TreeLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is TreeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<TreeBloc>().add(RefreshTreeEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is TreeLoaded) {
          // If graph is empty (e.g. initial load), build it once
          if (graph.nodes.isEmpty) {
            _buildGraph(state);
            _centerRootNode();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final configuration = BuchheimWalkerConfiguration()
                ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM
                ..siblingSeparation = 150
                ..levelSeparation = 200
                ..subtreeSeparation = 200;

              return InteractiveViewer(
                transformationController: _transformationController,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(2000),
                minScale: 0.01,
                maxScale: 5,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    configuration,
                    TreeEdgeRenderer(configuration),
                  ),
                  builder: (Node node) {
                    final nodeId = node.key!.value as String;
                    final treeNode = state.allNodes[nodeId];
                    if (treeNode == null) return const SizedBox.shrink();

                    final isMatch = widget.searchQuery.isEmpty || 
                        treeNode.person.name.toLowerCase().contains(widget.searchQuery.toLowerCase());

                    return Opacity(
                      opacity: isMatch ? 1.0 : 0.3,
                      child: PersonCardWidget(
                        node: treeNode,
                        showExpandButton: treeNode.children.isNotEmpty,
                        onTap: () {
                          if (treeNode.person.id != 'virtual_root') {
                            GoRouter.of(context).go('/person-details/${treeNode.person.id}');
                          }
                        },
                        onExpandToggle: () {
                          context.read<TreeBloc>().add(
                                ToggleNodeExpandCollapseEvent(
                                  personId: treeNode.person.id,
                                ),
                              );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        }

        return const Center(
          child: Text('No family tree data available'),
        );
      },
    );
  }
}
