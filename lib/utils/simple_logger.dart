import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SimpleLogger {
  static IOSink? _sink;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _sink = File('${dir.path}/harikar.log').openWrite(mode: FileMode.append);
  }

  static void log(String msg) {
    final ts = DateTime.now().toIso8601String();
    _sink?.writeln('[$ts] $msg');
  }
}
