import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../../../core/settings/cubit/settings_state.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../interview_call/data/services/gemini_config.dart';
import '../../domain/entities/interview_track.dart';
import '../../domain/repositories/tracks_repository.dart';

class FirestoreTracksRepository implements TracksRepository {
  FirestoreTracksRepository(
    this._firestore,
    this._authRepository, {
    http.Client? client,
  }) : _client = client ?? http.Client();

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final http.Client _client;

  CollectionReference<Map<String, dynamic>> get _tracks {
    final user = _authRepository.currentUser;
    if (user == null) throw StateError('No hay un usuario autenticado.');
    return _firestore.collection('users').doc(user.uid).collection('tracks');
  }

  @override
  Future<List<InterviewTrack>> getTracks() async {
    final snapshot = await _tracks.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  @override
  Future<InterviewTrack?> getTrack(String trackId) async {
    final document = await _tracks.doc(trackId).get();
    return document.exists ? _fromDocument(document) : null;
  }

  @override
  Future<InterviewTrack> createTrack({
    required String title,
    required String company,
    required String jobDescription,
  }) async {
    final document = _tracks.doc();
    final data = {
      'title': title.trim(),
      'company': company.trim(),
      'jobDescription': jobDescription.trim(),
      'prepCompleted': false,
      'cyclesCompleted': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await document.set(data);
    final saved = await document.get();
    return _fromDocument(saved);
  }

  @override
  Future<void> markPrepCompleted(String trackId) {
    return _tracks.doc(trackId).update({
      'prepCompleted': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementCycle(String trackId) {
    return _tracks.doc(trackId).update({
      'cyclesCompleted': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<({String title, String company, String jobDescription})>
  generateFromDescription({
    required String input,
    required AppLanguage language,
  }) async {
    if (kGeminiApiKey.isEmpty) {
      throw StateError('Falta GEMINI_API_KEY.');
    }
    final prompt = language == AppLanguage.spanish
        ? 'A partir de este texto del usuario, extrae datos para un trayecto de entrevista. '
            'Responde solo JSON: {"title":string,"company":string,"jobDescription":string}. '
            'jobDescription debe resumir requisitos y contexto en máximo 120 palabras.\n\n$input'
        : 'From this user text, extract interview track data. '
            'Reply only JSON: {"title":string,"company":string,"jobDescription":string}. '
            'jobDescription must summarize requirements in max 120 words.\n\n$input';

    final response = await _client.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-flash-latest:generateContent?key=$kGeminiApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'responseMimeType': 'application/json'},
      }),
    );
    if (response.statusCode != 200) {
      throw StateError('No se pudo generar el trayecto (${response.statusCode}).');
    }
    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final text =
        json['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? '{}';
    final parsed = jsonDecode(text) as Map<String, dynamic>;
    return (
      title: (parsed['title'] as String? ?? '').trim(),
      company: (parsed['company'] as String? ?? '').trim(),
      jobDescription: (parsed['jobDescription'] as String? ?? '').trim(),
    );
  }

  InterviewTrack _fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final createdAt = data['createdAt'] as Timestamp?;
    return InterviewTrack(
      id: document.id,
      title: data['title'] as String? ?? '',
      company: data['company'] as String? ?? '',
      jobDescription: data['jobDescription'] as String? ?? '',
      prepCompleted: data['prepCompleted'] as bool? ?? false,
      cyclesCompleted: (data['cyclesCompleted'] as num?)?.toInt() ?? 0,
      createdAt: createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
