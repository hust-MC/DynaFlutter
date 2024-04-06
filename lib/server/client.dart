import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  final response = await http.get(Uri.parse('http://localhost:8080/version'));
  if (response.statusCode == HttpStatus.ok) {
    final version = response.body;
    print('fetch version: $version');
  } else {
    print('Failed to fetch version: ${response.reasonPhrase}');
  }
}

