import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for displaying AI response in a styled container
class ResponseBox extends StatelessWidget {
  final String response;
  final bool isLoading;
  final VoidCallback onSpeak;

  const ResponseBox({
    super.key,
    required this.response,
    required this.isLoading,
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
                IconButton(
                  onPressed: onSpeak,
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.blue.shade600,
                  ),
                  tooltip: 'Speak answer',
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


