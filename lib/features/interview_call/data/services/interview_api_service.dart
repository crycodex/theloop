import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/interview_report.dart';
import '../../domain/entities/transcript_turn.dart';

class LiveSessionCredentials {
  const LiveSessionCredentials({
    required this.token,
    required this.loopId,
    required this.model,
    required this.systemPrompt,
  });

  final String token;
  final String loopId;
  final String model;
  final String systemPrompt;

  factory LiveSessionCredentials.fromJson(Map<String, dynamic> json) {
    return LiveSessionCredentials(
      token: json['token'] as String? ?? '',
      loopId: json['loopId'] as String? ?? '',
      model: json['model'] as String? ?? '',
      systemPrompt: json['systemPrompt'] as String? ?? '',
    );
  }
}

class InterviewApiService {
  InterviewApiService(this._auth, {http.Client? client})
    : _client = client ?? http.Client();

  static const _defaultBaseUrl =
      'https://us-central1-the-loop-d46af.cloudfunctions.net';
  static const _baseUrl = String.fromEnvironment(
    'FUNCTIONS_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  final FirebaseAuth _auth;
  final http.Client _client;

  Future<LiveSessionCredentials> createLiveToken({
    String? sourceLoopId,
  }) async {
    final json = await _post('createLiveToken', {
      if (sourceLoopId != null && sourceLoopId.isNotEmpty)
        'sourceLoopId': sourceLoopId,
    });
    final credentials = LiveSessionCredentials.fromJson(json);
    if (credentials.token.isEmpty || credentials.loopId.isEmpty) {
      throw const InterviewApiException(
        'El servidor no devolvió una sesión válida.',
      );
    }
    return credentials;
  }

  Future<InterviewReport> generateReport({
    required String loopId,
    required List<TranscriptTurn> transcript,
    required int durationSeconds,
  }) async {
    final json = await _post('generateInterviewReport', {
      'loopId': loopId,
      'durationSeconds': durationSeconds,
      'transcript': transcript.map((turn) => turn.toJson()).toList(),
    });
    return InterviewReport.fromJson(
      Map<String, dynamic>.from(json['report'] as Map? ?? const {}),
    );
  }

  Future<Map<String, dynamic>> _post(
    String functionName,
    Map<String, dynamic> body,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const InterviewApiException('Debes iniciar sesión nuevamente.');
    }
    final idToken = await user.getIdToken();
    final response = await _client.post(
      Uri.parse('$_baseUrl/$functionName'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw InterviewApiException(
        decoded['error'] as String? ?? 'Error ${response.statusCode}.',
      );
    }
    return decoded;
  }

  void dispose() => _client.close();
}

class InterviewApiException implements Exception {
  const InterviewApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
