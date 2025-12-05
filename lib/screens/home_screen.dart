import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../widgets/mic_button.dart';
import '../widgets/response_box.dart';

/// Main home screen of the AI Assistant app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FocusNode _textFieldFocusNode = FocusNode();

  @override
  void dispose() {
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ethiopia AI Assistant',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Consumer<AiProvider>(
          builder: (context, aiProvider, child) {
            // Auto-focus text field when speech recognition is not supported
            if (aiProvider.shouldFocusTextField) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _textFieldFocusNode.requestFocus();
                aiProvider.clearFocusFlag();
              });
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Language Selection Dropdown
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: aiProvider.selectedLanguage,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey.shade700,
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade900,
                        ),
                        items: aiProvider.languages.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            aiProvider.updateSelectedLanguage(newValue);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Input Text Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      focusNode: _textFieldFocusNode,
                      controller: TextEditingController(
                        text: aiProvider.inputText.isEmpty
                            ? aiProvider.listeningText
                            : aiProvider.inputText,
                      )..selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: aiProvider.inputText.isEmpty
                                ? aiProvider.listeningText.length
                                : aiProvider.inputText.length,
                          ),
                        ),
                      onChanged: (value) {
                        aiProvider.updateInputText(value);
                      },
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: aiProvider.isListening
                            ? 'Listening...'
                            : 'Type your question here or use the mic',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.grey.shade900,
                      ),
                      enabled: !aiProvider.isLoading,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Listening indicator
                  if (aiProvider.isListening)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mic,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Listening...',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Mic Button and Send Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Microphone Button
                      Column(
                        children: [
                          const MicButton(),
                          const SizedBox(height: 8),
                          Text(
                            'Hold to speak',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 20),

                      // Send Button
                      ElevatedButton.icon(
                        onPressed: aiProvider.isLoading ||
                                (aiProvider.inputText.trim().isEmpty &&
                                    aiProvider.listeningText.trim().isEmpty)
                            ? null
                            : () {
                                aiProvider.sendQuestion();
                              },
                        icon: aiProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          'Send',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Response Box
                  ResponseBox(
                    response: aiProvider.responseText,
                    isLoading: aiProvider.isLoading,
                    isSpeaking: aiProvider.isSpeaking,
                    onSpeak: () {
                      if (aiProvider.isSpeaking) {
                        aiProvider.stopSpeaking();
                      } else {
                        aiProvider.speakResponse();
                      }
                    },
                  ),
                  
                  // Auto-play audio toggle
                  if (aiProvider.responseText.isNotEmpty && !aiProvider.isLoading)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.volume_up,
                                size: 20,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Auto-play audio',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: aiProvider.autoPlayAudio,
                            onChanged: (value) {
                              aiProvider.toggleAutoPlayAudio();
                            },
                            activeThumbColor: Colors.blue.shade600,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Info Text
                  if (!aiProvider.speechAvailable)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Note: Speech recognition is not available on this device.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // TTS Availability Warning
                  if (!aiProvider.ttsAvailable)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Audio playback not available',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please do a full app rebuild (not hot restart):\nflutter run',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.orange.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


