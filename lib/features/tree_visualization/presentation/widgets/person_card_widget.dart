import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../data/models/tree_node_data.dart';
import '../../../../core/router/routes.dart';

class PersonCardWidget extends StatelessWidget {
  final TreeNodeData node;
  final VoidCallback? onTap;
  final VoidCallback? onExpandToggle;
  final bool showExpandButton;

  const PersonCardWidget({
    super.key,
    required this.node,
    this.onTap,
    this.onExpandToggle,
    this.showExpandButton = false,
  });

  Color _getGenderColor(String? gender) {
    if (gender == null) return Colors.blue;
    switch (gender.toLowerCase()) {
      case 'male':
        return Colors.blue[700]!;
      case 'female':
        return Colors.pink[700]!;
      default:
        return Colors.purple[700]!;
    }
  }

  IconData _getGenderIcon(String? gender) {
    if (gender == null) return Icons.person;
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.man;
      case 'female':
        return Icons.woman;
      default:
        return Icons.person;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isVirtualRoot = node.person.id == 'virtual_root';

    if (isVirtualRoot) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              node.person.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (showExpandButton && node.children.isNotEmpty) ...[
              const SizedBox(height: 8),
              IconButton(
                icon: Icon(
                  node.isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: theme.colorScheme.primary,
                ),
                onPressed: onExpandToggle,
              ),
            ],
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGenderColor(node.person.gender),
              _getGenderColor(node.person.gender).withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Photo or Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white.withOpacity(0.3),
              backgroundImage: node.person.photoUrl != null
                  ? CachedNetworkImageProvider(node.person.photoUrl!)
                  : null,
              child: node.person.photoUrl == null
                  ? Icon(
                      _getGenderIcon(node.person.gender),
                      size: 32,
                      color: Colors.white,
                    )
                  : null,
            ),
            
            const SizedBox(height: 8),
            
            // Name
            Text(
              node.person.name,
              style: theme.textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Date of Birth (if available)
            if (node.person.dateOfBirth != null) ...[
              const SizedBox(height: 4),
              Text(
                'b. ${_formatDate(node.person.dateOfBirth)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
            
            // Children count badge
            if (node.children.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${node.children.length}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Expand/Collapse button (if has children)
            if (showExpandButton && node.children.isNotEmpty) ...[
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(
                  node.isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onExpandToggle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
