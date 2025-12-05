import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying AI response in a styled container
class ResponseBox extends StatelessWidget {
  final String response;
  final bool isLoading;
  final bool isSpeaking;
  final VoidCallback onSpeak;

  const ResponseBox({
    super.key,
    required this.response,
    required this.isLoading,
    this.isSpeaking = false,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Response',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              if (response.isNotEmpty && !isLoading)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSpeaking)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue.shade600,
                            ),
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: onSpeak,
                      icon: Icon(
                        isSpeaking ? Icons.stop : Icons.volume_up,
                        color: isSpeaking 
                            ? Colors.red.shade600 
                            : Colors.blue.shade600,
                      ),
                      tooltip: isSpeaking 
                          ? 'Stop audio' 
                          : 'Play audio response',
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (response.isEmpty)
            Text(
              'Your response will appear here...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            SelectableText(
              response,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade900,
                height: 1.5,
              ),
            ),
        ],
      ),
    );
  }
}


