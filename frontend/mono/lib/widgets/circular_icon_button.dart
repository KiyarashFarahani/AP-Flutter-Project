import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        backgroundColor: backgroundColor,
        foregroundColor: iconColor,
        elevation: 4,
      ),
      child: Icon(icon, color: iconColor),
    );
  }
}