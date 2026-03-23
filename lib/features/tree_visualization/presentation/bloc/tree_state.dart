import 'package:equatable/equatable.dart';
import '../../data/models/tree_node_data.dart';

abstract class TreeState extends Equatable {
  const TreeState();

  @override
  List<Object?> get props => [];
}

class TreeInitial extends TreeState {}

class TreeLoading extends TreeState {}

class TreeLoaded extends TreeState {
  final TreeNodeData root;
  final Map<String, TreeNodeData> allNodes;

  const TreeLoaded({required this.root, required this.allNodes});

  @override
  List<Object?> get props => [root, allNodes];
}

class TreeError extends TreeState {
  final String message;

  const TreeError({required this.message});

  @override
  List<Object?> get props => [message];
}
