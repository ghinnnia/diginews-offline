import 'package:flutter/services.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('id.ac.utd.diginews/native');

  static Future<void> reverseAndToastNIM(String nim) async {
    try {
      // Mengirim argumen dengan key 'nim' ke Kotlin
      await _channel.invokeMethod('reverseNIM', {'nim': nim});
    } on PlatformException catch (e) {
      print("Gagal memanggil native channel: ${e.message}");
    }
  }
}