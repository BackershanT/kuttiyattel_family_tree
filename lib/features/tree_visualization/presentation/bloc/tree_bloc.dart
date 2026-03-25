import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/tree_repository.dart';
import '../../data/models/tree_node_data.dart';
import 'bloc.dart';

class TreeBloc extends Bloc<TreeEvent, TreeState> {
  final TreeRepository repository;

  TreeBloc({required this.repository}) : super(TreeInitial()) {
    on<LoadTreeDataEvent>(_onLoadTreeData);
    on<ToggleNodeExpandCollapseEvent>(_onToggleNodeExpandCollapse);
    on<RefreshTreeEvent>(_onRefreshTree);
  }

  Future<void> _onLoadTreeData(
    LoadTreeDataEvent event,
    Emitter<TreeState> emit,
  ) async {
    try {
      print('═══════════════════════════════════════════════════');
      print('TREE BLOC: Loading tree data...');
      emit(TreeLoading());
      
      final root = await repository.buildFamilyTree();
      print('Repository returned root: ${root != null ? "${root.person.name} (${root.person.id})" : "NULL"}');
      
      if (root == null) {
        print('No family tree data found!');
        print('═══════════════════════════════════════════════════');
        emit(const TreeError(message: 'No family tree data found'));
        return;
      }

      // Build map of all nodes for quick lookup
      final allNodes = <String, TreeNodeData>{};
      _collectAllNodes(root, allNodes);
      
      print('Tree loaded successfully:');
      print('  - Root: ${root.person.name}');
      print('  - Total nodes: ${allNodes.length}');
      print('═══════════════════════════════════════════════════');

      emit(TreeLoaded(root: root, allNodes: allNodes));
    } catch (e) {
      print('Tree loading error: $e');
      print('═══════════════════════════════════════════════════');
      emit(TreeError(message: e.toString()));
    }
  }

  void _onToggleNodeExpandCollapse(
    ToggleNodeExpandCollapseEvent event,
    Emitter<TreeState> emit,
  ) {
    final currentState = state;
    if (currentState is TreeLoaded) {
      final node = currentState.allNodes[event.personId];
      if (node != null) {
        node.isExpanded = !node.isExpanded;
        
        // Rebuild the tree structure
        final updatedRoot = _updateNodeInTree(currentState.root, node);
        emit(TreeLoaded(root: updatedRoot, allNodes: currentState.allNodes));
      }
    }
  }

  void _onRefreshTree(
    RefreshTreeEvent event,
    Emitter<TreeState> emit,
  ) {
    add(LoadTreeDataEvent());
  }

  void _collectAllNodes(TreeNodeData node, Map<String, TreeNodeData> map) {
    map[node.person.id] = node;
    for (final child in node.children) {
      _collectAllNodes(child, map);
    }
  }

  TreeNodeData _updateNodeInTree(TreeNodeData root, TreeNodeData targetNode) {
    if (root.person.id == targetNode.person.id) {
      return targetNode;
    }
    
    final updatedChildren = root.children.map((child) {
      return _updateNodeInTree(child, targetNode);
    }).toList();

    return TreeNodeData(
      person: root.person,
      spouse: root.spouse,
      children: updatedChildren,
      isExpanded: root.isExpanded,
      depth: root.depth,
    );
  }
}
