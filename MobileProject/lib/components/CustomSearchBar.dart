import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:barcode_scan2/barcode_scan2.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;

  const CustomSearchBar({Key? key, required this.onSearch}) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Normalize search input by converting to lowercase and trimming spaces
  String _normalizeSearchQuery(String query) {
    // Remove extra spaces and trim leading/trailing spaces
    query = query.trim();
    // Replace multiple spaces with a single space
    query = query.replaceAll(RegExp(r'\s+'), ' ');
    // Convert to lowercase for case-insensitive search
    return query.toLowerCase();
  }

  void _startVoiceSearch() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });

          // Automatically trigger the search when the user stops speaking
          if (result.finalResult) {
            _speechToText.stop();
            setState(() => _isListening = false);
            // Normalize query before passing it to the search
            widget.onSearch(_normalizeSearchQuery(result.recognizedWords));
          }
        });
      }
    } else {
      setState(() => _isListening = false);
      _speechToText.stop();
    }
  }

  void _scanBarcode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      setState(() {
        _controller.text = result.rawContent;
      });
      // Normalize query before passing it to the search
      widget.onSearch(_normalizeSearchQuery(result.rawContent));
    } catch (e) {
      print('Error scanning barcode: $e');
    }
  }

  void _search() {
    // Normalize the search query before triggering the search
    widget.onSearch(_normalizeSearchQuery(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) => _search(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.mic),
          onPressed: _startVoiceSearch,
          color: _isListening ? Colors.red : null,
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: _scanBarcode,
        ),
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _search,
        ),
      ],
    );
  }
}
