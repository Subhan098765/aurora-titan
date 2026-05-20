import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/result.dart';

final resourcesProvider = FutureProvider<Result<List<dynamic>>>((ref) async {
  try {
    final response = await http
        .get(Uri.parse('https://aurora-titan-896824917672.europe-west1.run.app/api/v1/resources'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      return Success(jsonDecode(response.body) as List<dynamic>);
    } else {
      return Failure('Failed to load resources: ${response.statusCode}');
    }
  } catch (e) {
    return Failure('Network error while loading resources', e);
  }
});
