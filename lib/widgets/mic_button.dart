import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';

/// Custom microphone button widget with press-and-hold functionality
class MicButton extends StatefulWidget {
  const MicButton({super.key});

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiProvider>(
      builder: (context, aiProvider, child) {
        final isListening = aiProvider.isListening;

        return GestureDetector(
          onLongPressStart: (_) {
            if (aiProvider.speechAvailable && !isListening) {
              aiProvider.startListening();
              _animationController.forward();
            }
          },
          onLongPressEnd: (_) {
            if (isListening) {
              aiProvider.stopListening();
              _animationController.reset();
            }
          },
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: isListening ? _scaleAnimation.value : 1.0,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening
                        ? Colors.red.shade400
                        : Colors.blue.shade600,
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.shade300.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.blue.shade300.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}



