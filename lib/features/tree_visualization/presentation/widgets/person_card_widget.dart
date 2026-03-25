import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
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
    if (node.person.id == 'virtual_root') {
      return _buildVirtualRoot(context);
    }

    if (node.spouse != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPersonCard(context, node.person, onTap),
          _buildSpouseConnector(context),
          _buildPersonCard(context, node.spouse!, () {
            GoRouter.of(context).go('/person-details/${node.spouse!.id}');
          }),
          if (showExpandButton && node.children.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildExpandButton(context),
          ],
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildPersonCard(context, node.person, onTap),
        if (showExpandButton && node.children.isNotEmpty) ...[
          const SizedBox(width: 8),
          _buildExpandButton(context),
        ],
      ],
    );
  }

  Widget _buildVirtualRoot(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_tree, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            'Kuttiyattel Family',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (showExpandButton && node.children.isNotEmpty) ...[
            const SizedBox(width: 8),
            _buildExpandButton(context, isWhite: true),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonCard(BuildContext context, dynamic person, VoidCallback? tapHandler) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: tapHandler,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _getGenderColor(person.gender).withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.surfaceVariant,
                backgroundImage: person.photoUrl != null
                    ? CachedNetworkImageProvider(person.photoUrl!)
                    : null,
                child: person.photoUrl == null
                    ? Icon(
                        _getGenderIcon(person.gender),
                        size: 20,
                        color: _getGenderColor(person.gender),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            // Name and Role
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  person.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  person.gender ?? 'Member',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpouseConnector(BuildContext context) {
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.pink.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Center(
        child: Icon(
          Icons.favorite,
          size: 10,
          color: Colors.pink.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildExpandButton(BuildContext context, {bool isWhite = false}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onExpandToggle,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isWhite ? Colors.white24 : theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          node.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 16,
          color: isWhite ? Colors.white : theme.colorScheme.primary,
        ),
      ),
    );
  }
}
