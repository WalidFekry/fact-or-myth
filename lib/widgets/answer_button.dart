import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AnswerButton extends StatefulWidget {
  final String text;
  final bool isTrue;
  final VoidCallback onPressed;
  final bool? isSelected;
  final bool? isCorrect;
  final bool? correctAnswer; // Add correct answer to show green on correct option

  const AnswerButton({
    super.key,
    required this.text,
    required this.isTrue,
    required this.onPressed,
    this.isSelected,
    this.isCorrect,
    this.correctAnswer,
  });

  @override
  State<AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<AnswerButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _bounceAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );
  }

  @override
  void didUpdateWidget(AnswerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != null && oldWidget.isSelected == null) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData? icon;

    // Determine button state and color
    if (widget.isSelected != null) {
      // After answer is submitted
      final isThisButtonCorrect = widget.isTrue == widget.correctAnswer;
      final isThisButtonSelected = widget.isSelected == true;

      if (isThisButtonCorrect) {
        // This is the correct answer - always show green
        backgroundColor = AppColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
      } else if (isThisButtonSelected) {
        // This button was selected but is wrong - show red
        backgroundColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.cancel_rounded;
      } else {
        // Not selected and not correct - neutral
        backgroundColor = Theme.of(context).cardColor ?? AppColors.primaryDark.withOpacity(0.3);
        textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
      }
    } else {
      // Before answer is submitted
      backgroundColor = AppColors.primaryDark;
      textColor = Colors.white;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final scale = widget.isSelected != null 
            ? (_animationController.value < 0.5 
                ? _scaleAnimation.value 
                : _bounceAnimation.value)
            : (_isPressed ? 0.97 : 1.0);
        
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTapDown: widget.isSelected == null ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: widget.isSelected == null ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: widget.isSelected == null ? () => setState(() => _isPressed = false) : null,
            onTap: widget.isSelected == null ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isSelected != null
                    ? [
                        BoxShadow(
                          color: backgroundColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Icon(icon, color: textColor, size: 20),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}