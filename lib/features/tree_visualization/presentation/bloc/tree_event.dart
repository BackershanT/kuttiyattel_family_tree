import 'package:equatable/equatable.dart';

abstract class TreeEvent extends Equatable {
  const TreeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTreeDataEvent extends TreeEvent {}

class ToggleNodeExpandCollapseEvent extends TreeEvent {
  final String personId;

  const ToggleNodeExpandCollapseEvent({required this.personId});

  @override
  List<Object?> get props => [personId];
}

class RefreshTreeEvent extends TreeEvent {}
