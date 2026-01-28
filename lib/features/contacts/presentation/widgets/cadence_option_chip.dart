import 'package:flutter/material.dart';

class CadenceOptionChip extends StatelessWidget {
  const CadenceOptionChip({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  static const _activeColor = Color(0xFF4C6EF5);
  static const _borderColor = Color(0x14000000);
  static const _secondary = Color(0xFFF1F5F9);
  static const _muted = Color(0xFF8B95A1);

  @override
  Widget build(BuildContext context) {
    final iconBackground = selected ? _activeColor : _secondary;
    final iconColor = selected ? Colors.white : Colors.black87;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onSelected,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? _activeColor : _borderColor,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _activeColor.withOpacity(0.1),
                      blurRadius: 0,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: iconBackground,
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _muted,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? _activeColor : Colors.transparent,
                  border: Border.all(
                    color: selected ? _activeColor : _borderColor,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
