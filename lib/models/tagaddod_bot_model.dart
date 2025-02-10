import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ChatbotModel {
  Interpreter? _interpreter;
  Map<String, int>? _wordIndex;
  int maxSequenceLength = 7; // Adjust based on training

  ChatbotModel() {
    _loadModel();
    _loadTokenizer();
  }

  /// Load the TFLite model
  Future<void> _loadModel() async {
    var opt = InterpreterOptions()
      ..useFlexDelegateAndroid = true
      ..useNnApiForAndroid = true;

    _interpreter =
        await Interpreter.fromAsset('chatbot_model.tflite', options: opt);
    print("✅ Model loaded successfully");
  }

  /// Load tokenizer dictionary (exported from Python)
  Future<void> _loadTokenizer() async {
    String jsonString = await rootBundle.loadString('assets/word_index.json');
    _wordIndex = Map<String, int>.from(json.decode(jsonString));
    print("✅ Word index loaded: ${_wordIndex?.length} words");
    print("📝 Word index sample: ${_wordIndex?.keys.take(10).toList()}");
  }

  /// Preprocess text (match training format)
  String _preprocessText(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ''); // Remove punctuation
  }

  /// Tokenize input text
  List<int> _tokenizeText(String text) {
    if (_wordIndex == null) {
      print("❌ Word index not loaded yet!");
      return List.filled(maxSequenceLength, 0);
    }

    // text = _preprocessText(text); // Apply preprocessing
    debugPrint("Text is $text");
    List<int> sequence = text.split(' ').map((word) {
      int token =
          _wordIndex?[word] ?? _wordIndex?["<OOV>"] ?? 0; // Fallback to <OOV>
      print("🔹 Word: $word, Token: $token");
      return token;
    }).toList();

    // Pad or truncate the sequence
    while (sequence.length < maxSequenceLength) {
      sequence.add(0); // Add padding
    }
    return sequence.sublist(0, maxSequenceLength); // Ensure fixed length
  }

  /// Predict intent
  Future<String> predict(String inputText) async {
    List<int> inputVector = _tokenizeText(inputText);
    debugPrint("🔹 Tokenized Input: $inputVector");
    List<List<int>> inputBatch = [inputVector];
    List<List<double>> output = [List.filled(7, 0.0)];

    _interpreter?.run(inputBatch, output);
    debugPrint("🔹 Model Output: $output");

    int predictedIndex = _argMax(output[0]); // Get highest probability index
    debugPrint("🔹 Predicted Index: $predictedIndex");

    String predictedTag = _getTagFromIndex(predictedIndex);
    debugPrint("🔹 Predicted Tag: $predictedTag");

    return predictedTag;
  }

  /// Find max index in output vector
  int _argMax(List<double> list) {
    return list.indexOf(list.reduce((a, b) => a > b ? a : b));
  }

  /// Convert predicted index to tag
  String _getTagFromIndex(int index) {
    List<String> tags = [
      "provide_quantity",
      "provide_address",
      "choose_gift",
      "submit_order",
      "greeting",
      "goodbye",
      "fallback"
    ];
    return tags[index];
  }

  void close() {
    _interpreter?.close();
  }
}
