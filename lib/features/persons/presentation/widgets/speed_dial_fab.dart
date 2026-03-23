import 'package:flutter/material.dart';

/// Enhanced Floating Action Button with speed dial functionality
class SpeedDialFAB extends StatefulWidget {
  final FloatingActionButton onMainPressed;
  final List<SpeedDialAction> actions;
  final bool isOpen;
  final ValueChanged<bool>? onIsOpenChanged;

  const SpeedDialFAB({
    super.key,
    required this.onMainPressed,
    required this.actions,
    this.isOpen = false,
    this.onIsOpenChanged,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.isOpen;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isOpen) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
      widget.onIsOpenChanged?.call(_isOpen);
    });
  }

  void _close() {
    if (_isOpen) {
      setState(() {
        _isOpen = false;
        _animationController.reverse();
        widget.onIsOpenChanged?.call(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Action buttons
        ScaleTransition(
          scale: _animation,
          child: FadeTransition(
            opacity: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                return Transform.translate(
                  offset: Offset(
                    0,
                    -((widget.actions.length - index) * 60.0),
                  ),
                  child: _buildActionButton(action, index),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Main FAB
        FloatingActionButton(
          heroTag: 'mainFab',
          onPressed: _toggle,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animation,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(SpeedDialAction action, int index) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _close();
          action.onPressed();
        },
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: action.backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                color: action.iconColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                action.label,
                style: TextStyle(
                  color: action.textColor ?? Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Action for speed dial
class SpeedDialAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
  });
}
