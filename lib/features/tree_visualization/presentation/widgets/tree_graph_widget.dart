import 'package:flutter/material.dart';
import 'package:graphview/graphview.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/bloc.dart';
import '../../data/models/tree_node_data.dart';
import '../widgets/widgets.dart';
import '../../../../core/router/routes.dart';

class TreeGraphWidget extends StatefulWidget {
  const TreeGraphWidget({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TreeBloc, TreeState>(
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
          // Debug logging
          print('═══════════════════════════════════════════════════');
          print('TREE DATA LOADED');
          print('Total nodes in state: ${state.allNodes.length}');
          print('Root person: ${state.root.person.name} (${state.root.person.id})');
          
          // Build graph if empty or if data changed
          if (graph.nodes.isEmpty || graph.nodes.length != nodeMap.length) {
            print('Building graph...');
            _buildGraph(state);
            print('Graph built with ${graph.nodes.length} nodes');
            
            // Print all node keys for debugging
            print('Node keys in graph:');
            var count = 0;
            for (var node in graph.nodes) {
              if (count < 10) { // Print first 10 nodes
                print('  - Node ${count + 1}: key=${node.key?.value ?? "NULL"}, ID=${node.key?.value ?? "N/A"}');
                count++;
              }
            }
          } else {
            print('Graph already built with ${graph.nodes.length} nodes');
          }
          print('═══════════════════════════════════════════════════');

          return LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(300),
                minScale: 0.01,
                maxScale: 5,
                child: SizedBox(
                  width: constraints.maxWidth * 3,
                  height: constraints.maxHeight * 3,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(
                      BuchheimWalkerConfiguration(),
                      TreeEdgeRenderer(BuchheimWalkerConfiguration()),
                    ),
                    builder: (Node node) {
                  // Add comprehensive null safety checks with debug logging
                  print('🔍 Builder called for node');
                  
                  if (node.key == null) {
                    print('❌ ERROR: Node has null key');
                    return Container(
                      width: 150,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'Invalid Node',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    );
                  }
                  
                  print('  Node key exists: ${node.key}');
                  final nodeId = node.key!.value;
                  print('  Node ID value: $nodeId');
                  
                  if (nodeId == null) {
                    print('❌ ERROR: Node key value is null');
                    return Container(
                      width: 150,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          'No ID',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    );
                  }
                  
                  print('  Looking up treeNode for: $nodeId');
                  final treeNode = state.allNodes[nodeId];
                  if (treeNode == null) {
                    print('⚠️ TreeNode not found for ID: $nodeId');
                    return const SizedBox.shrink();
                  }

                  print('✅ Rendering: ${treeNode.person.name}');
                  return PersonCardWidget(
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
                  );
                },
              ),
            ),
          );
        }

        return const Center(
          child: Text('No family tree data available'),
        );
      },
      }
    );
  }
}
