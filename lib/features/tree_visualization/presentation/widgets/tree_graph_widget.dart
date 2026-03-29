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
  Graph? _graph;
  Map<String, Node>? _nodeMap;
  BuchheimWalkerConfiguration? _configuration;
  BuchheimWalkerAlgorithm? _algorithm;
  bool _isInitialized = false;

  Graph get graph {
    _graph ??= Graph();
    return _graph!;
  }

  Map<String, Node> get nodeMap {
    _nodeMap ??= {};
    return _nodeMap!;
  }

  BuchheimWalkerConfiguration get configuration {
    if (!_isInitialized) _initGraphView();
    return _configuration!;
  }

  BuchheimWalkerAlgorithm get algorithm {
    if (!_isInitialized) _initGraphView();
    return _algorithm!;
  }

  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _initGraphView();
    _transformationController.addListener(_onTransformationChanged);
    
    // Initial build if state is already loaded
    final state = context.read<TreeBloc>().state;
    if (state is TreeLoaded) {
      // Use microtask to avoid calling setState during initialization
      Future.microtask(() => _buildGraph(state));
    }
  }

  void _initGraphView() {
    _graph ??= Graph();
    _nodeMap ??= {};
    
    if (_isInitialized && _configuration != null && _algorithm != null) return;
    
    // Initialize configuration and algorithm once
    _configuration = BuchheimWalkerConfiguration()
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM
      ..siblingSeparation = 150
      ..levelSeparation = 200
      ..subtreeSeparation = 200;
      
    _algorithm = BuchheimWalkerAlgorithm(
      _configuration!,
      TreeEdgeRenderer(_configuration!),
    );
    
    _isInitialized = true;
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale.isFinite && !scale.isNaN) {
      widget.onScaleChanged?.call(scale);
    }
  }

  void _buildGraph(TreeLoaded state) {
    final newGraph = Graph();
    final newNodeMap = <String, Node>{};

    // Build nodes and edges recursively
    _addNodeAndChildrenToGraph(state.root, newGraph, newNodeMap);

    // Update state once fully built
    if (mounted) {
      setState(() {
        _graph = newGraph;
        _nodeMap = newNodeMap;
      });
    }
  }

  void _addNodeAndChildrenToGraph(TreeNodeData treeNode, Graph targetGraph, Map<String, Node> targetNodeMap) {
    // Create node if not exists
    if (!targetNodeMap.containsKey(treeNode.person.id)) {
      final graphNode = Node.Id(treeNode.person.id);
      targetNodeMap[treeNode.person.id] = graphNode;
      targetGraph.addNode(graphNode);
    }

    final parentNode = targetNodeMap[treeNode.person.id]!;

    // Add children and edges
    for (final child in treeNode.children) {
      if (!targetNodeMap.containsKey(child.person.id)) {
        final childNode = Node.Id(child.person.id);
        targetNodeMap[child.person.id] = childNode;
        targetGraph.addNode(childNode);
      }

      final childNode = targetNodeMap[child.person.id]!;
      targetGraph.addEdge(parentNode, childNode);
      
      // Recursively add grandchildren
      _addNodeAndChildrenToGraph(child, targetGraph, targetNodeMap);
    }
  }

  // Removed old recursive helper replaced by _addNodeAndChildrenToGraph


  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _centerRootNode() {
    // Delay slightly to ensure layout is done
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _transformationController.value = Matrix4.identity();
    });
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
        // Ensure algorithm and other fields are initialized at the very start of build
        _initGraphView();

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
          return InteractiveViewer(
            transformationController: _transformationController,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(5000), // Increased margin
            minScale: 0.001, // Allow zooming out more
            maxScale: 2.0,
            child: SizedBox(
               // Large canvas to ensure graph is never constrained
              width: 10000,
              height: 10000,
              child: Align(
                alignment: Alignment.topLeft,
                child: GraphView(
                  graph: graph,
                  algorithm: algorithm,
                  builder: (Node node) {
                    final key = node.key;
                    if (key == null || key is! ValueKey) {
                      return const SizedBox.shrink();
                    }
                    
                    final nodeId = key.value as String;
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
                            GoRouter.of(context).push('/person-details/${treeNode.person.id}');
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
              ),
            ),
          );
        }

        return const Center(
          child: Text('No family tree data available'),
        );
      },
    );
  }
}
