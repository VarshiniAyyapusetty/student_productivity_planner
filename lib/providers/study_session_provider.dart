import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/study_session.dart';

class StudySessionProvider extends ChangeNotifier {
  static const String _storageKey = 'study_planner_sessions';

  final List<StudySession> _sessions = [];
  bool _isLoading = true;

  List<StudySession> get sessions => List.unmodifiable(_sessions);
  bool get isLoading => _isLoading;

  int get totalMinutes =>
      _sessions.fold(0, (total, session) => total + session.durationMinutes);

  int get todayMinutes {
    final today = _today;
    return _sessions
        .where((session) => _isSameDay(session.date, today))
        .fold(0, (total, session) => total + session.durationMinutes);
  }

  List<StudySession> get todaySessions {
    final today = _today;

    return _sessions
        .where((session) => _isSameDay(session.date, today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> loadSessions() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_storageKey);

      if (saved != null) {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _sessions
          ..clear()
          ..addAll(
            decoded.map(
              (item) =>
                  StudySession.fromJson(Map<String, dynamic>.from(item as Map)),
            ),
          );
      }
    } catch (error) {
      debugPrint('Could not load study sessions: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveSessions() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _sessions.map((session) => session.toJson()).toList(),
      );
      await preferences.setString(_storageKey, encoded);
    } catch (error) {
      debugPrint('Could not save study sessions: $error');
    }
  }

  void addSession(StudySession session) {
    _sessions.add(session);
    notifyListeners();
    _saveSessions();
  }

  void updateSession(StudySession updated) {
    final index = _sessions.indexWhere((session) => session.id == updated.id);

    if (index == -1) return;

    _sessions[index] = updated;
    notifyListeners();
    _saveSessions();
  }

  void deleteSession(String id) {
    _sessions.removeWhere((session) => session.id == id);
    notifyListeners();
    _saveSessions();
  }
}
