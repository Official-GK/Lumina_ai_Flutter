// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_model.dart';
import '../models/course_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';

class ApiService {
  // ── Config ────────────────────────────────────────────────────────────────
  // Change this to your Render URL once deployed:
  // static const String overrideBaseUrl = 'https://lumina-career-api.onrender.com';
  static String get baseUrl {
    if (kIsWeb) return 'http://13.53.37.54:8000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://13.53.37.54:8000';
    }
    return 'http://13.53.37.54:8000';
  }

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // ── Auth header ──────────────────────────────────────────────────────────
  Future<Map<String, String>> _authHeaders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final token = await user.getIdToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESUME ANALYSIS — Web + Mobile compatible (uses raw bytes)
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> analyzeResumeBytes(
      Uint8List fileBytes, String fileName, String targetCareer) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not authenticated');
    final token = await user.getIdToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/analyze-resume'),
    )
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['target_career'] = targetCareer
      ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

    final streamed = await request.send().timeout(const Duration(seconds: 90));
    final body = await streamed.stream.bytesToString();
    final decoded = json.decode(body);

    if (streamed.statusCode == 200) {
      final data = decoded['data'] as Map<String, dynamic>;
      final warning = decoded['warning'] as String?;
      // Return data + attach any warning so caller can show it
      return {'data': data, 'warning': warning, 'status': decoded['status']};
    }
    throw ApiException(
        decoded['detail'] ?? 'Resume analysis failed', streamed.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CHAT ASSISTANT
  // ─────────────────────────────────────────────────────────────────────────
  Future<String> sendChat(
      String message, List<Map<String, String>> history) async {
    final headers = await _authHeaders();
    final res = await http
        .post(
          Uri.parse('$baseUrl/api/chat-assistant'),
          headers: headers,
          body: json.encode({'user_message': message, 'history': history}),
        )
        .timeout(const Duration(seconds: 30));

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) return decoded['reply'] as String;
    throw ApiException(decoded['detail'] ?? 'Chat failed', res.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JOB RECOMMENDATIONS
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getJobs(List<String> skills) async {
    final headers = await _authHeaders();
    final skillParam = skills.join(',');
    final res = await http
        .get(
          Uri.parse('$baseUrl/api/recommend-jobs?skills=$skillParam'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) {
      return List<Map<String, dynamic>>.from(decoded['jobs']);
    }
    throw ApiException(decoded['detail'] ?? 'Jobs fetch failed', res.statusCode);
  }

  Future<List<JobModel>> fetchRecommendedJobs({String skills = 'Flutter', String country = 'in'}) async {
    final headers = await _authHeaders();
    final res = await http
        .get(
          Uri.parse('$baseUrl/api/recommend-jobs?skills=$skills&country=$country'),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) {
      final jobsList = decoded['jobs'] as List;
      return jobsList.map((j) => JobModel.fromJson(j)).toList();
    }
    throw ApiException(decoded['detail'] ?? 'Jobs fetch failed', res.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COURSE RECOMMENDATIONS
  // ─────────────────────────────────────────────────────────────────────────
  Future<List<CourseModel>> fetchRecommendedCourses({required String skills}) async {
    final headers = await _authHeaders();
    final res = await http
        .get(
          Uri.parse("$baseUrl/api/recommend-courses?skills=$skills"),
          headers: headers,
        )
        .timeout(const Duration(seconds: 15));

    final decoded = json.decode(res.body);
    if (res.statusCode == 200) {
      final coursesList = decoded["courses"] as List;
      return coursesList.map((c) => CourseModel.fromJson(c)).toList();
    }
    throw ApiException(decoded["detail"] ?? "Courses fetch failed", res.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // USER PROFILE (from Firestore via backend)
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile() async {
    final headers = await _authHeaders();
    final res = await http
        .get(Uri.parse('$baseUrl/api/profile'), headers: headers)
        .timeout(const Duration(seconds: 15));
    final decoded = json.decode(res.body);
    if (res.statusCode == 200) return decoded['profile'] as Map<String, dynamic>;
    throw ApiException(decoded['detail'] ?? 'Profile fetch failed', res.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROADMAP
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getRoadmap() async {
    final headers = await _authHeaders();
    final res = await http
        .get(Uri.parse('$baseUrl/api/roadmap'), headers: headers)
        .timeout(const Duration(seconds: 15));
    final decoded = json.decode(res.body);
    if (res.statusCode == 200) return decoded['roadmap'] as Map<String, dynamic>;
    throw ApiException(decoded['detail'] ?? 'Roadmap fetch failed', res.statusCode);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PORTFOLIO
  // ─────────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getPortfolio() async {
    final headers = await _authHeaders();
    final res = await http
        .get(Uri.parse('$baseUrl/api/portfolio'), headers: headers)
        .timeout(const Duration(seconds: 15));
    final decoded = json.decode(res.body);
    if (res.statusCode == 200) return decoded['portfolio'] as Map<String, dynamic>;
    throw ApiException(
        decoded['detail'] ?? 'Portfolio fetch failed', res.statusCode);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom exception with HTTP status code
// ─────────────────────────────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
