import 'package:flutter/material.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
    this.gradient,
    this.backgroundColor,
    this.boxShadow,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.loading;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : (widget.gradient ??
                    const LinearGradient(
                      colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                    )),
            color: isDisabled
                ? Colors.grey.shade400
                : (widget.gradient == null ? widget.backgroundColor : null),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isDisabled
                ? []
                : (widget.boxShadow ??
                    [
                      BoxShadow(
                        color: const Color(0xFFF39C12).withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]),
          ),
          alignment: Alignment.center,
          child: widget.loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
