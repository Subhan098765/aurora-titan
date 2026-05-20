import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/result.dart';

final mapCrisesProvider = FutureProvider<Result<List<dynamic>>>((ref) async {
  try {
    final response = await http
        .get(Uri.parse('https://aurora-titan-1-896824917672.europe-west1.run.app/api/v1/crises/live'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return Success(data['crises'] as List<dynamic>);
      } else {
        return Failure(data['message'] ?? 'Unknown API error');
      }
    } else {
      return Failure('Failed to load map data: ${response.statusCode}');
    }
  } catch (e) {
    return Failure('Network error while loading map data', e);
  }
});
