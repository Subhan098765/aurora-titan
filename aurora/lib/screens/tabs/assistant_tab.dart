import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/aurora_theme.dart';
import 'package:http/http.dart' as http;

class AssistantTab extends StatefulWidget {
  const AssistantTab({super.key});

  @override
  State<AssistantTab> createState() => _AssistantTabState();
}

class _AssistantTabState extends State<AssistantTab> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _sendMessage() async {
    final query = _controller.text.trim();
    if (query.isEmpty && _selectedImage == null) return;
    
    Uint8List? imageBytes;
    String? base64Image;
    if (_selectedImage != null) {
      imageBytes = await _selectedImage!.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    setState(() {
      _messages.add(_ChatMessage(
        content: query.isEmpty ? '[Image Uploaded]' : query,
        isUser: true,
        hasImage: _selectedImage != null,
        imageBytes: imageBytes,
      ));
      _loading = true;
      _selectedImage = null;
    });
    _controller.clear();
    
    try {
      final response = await http
          .post(Uri.parse('https://aurora-titan-896824917672.europe-west1.run.app/api/v1/chat'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'question': query.isEmpty ? 'Analyze this image.' : query, 'image_base64': base64Image}))
          .timeout(const Duration(seconds: 15)); // Vision takes longer
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['answer'] ?? 'No response.';
        setState(() {
          _messages.add(_ChatMessage(content: answer, isUser: false));
        });
      } else {
        setState(() {
          _messages.add(_ChatMessage(content: 'Error: ${response.statusCode}', isUser: false));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage(content: 'Exception: $e', isUser: false));
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('AI COPILOT', style: TextStyle(color: AuroraTheme.primaryNeon, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2)),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AuroraTheme.primaryNeon.withValues(alpha: 0.2) : AuroraTheme.surface.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.hasImage)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: msg.imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      constraints: const BoxConstraints(maxHeight: 180),
                                      child: Image.memory(
                                        msg.imageBytes!,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.image, color: AuroraTheme.primaryNeon),
                          ),
                        Text(msg.content, style: TextStyle(color: msg.isUser ? AuroraTheme.primaryNeon : AuroraTheme.textMain)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.image, color: AuroraTheme.secondaryNeon, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Image Selected: ${_selectedImage!.name}', style: const TextStyle(color: AuroraTheme.secondaryNeon, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
            ),
          if (_loading) const LinearProgressIndicator(color: AuroraTheme.primaryNeon),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_camera, color: AuroraTheme.primaryNeon),
                  onPressed: _loading ? null : _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask the Antigravity AI…',
                      hintStyle: const TextStyle(color: AuroraTheme.textMuted),
                      filled: true,
                      fillColor: AuroraTheme.background.withValues(alpha: 0.8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AuroraTheme.primaryNeon)),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AuroraTheme.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String content;
  final bool isUser;
  final bool hasImage;
  final Uint8List? imageBytes;
  _ChatMessage({required this.content, required this.isUser, this.hasImage = false, this.imageBytes});
}
