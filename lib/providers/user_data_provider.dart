// lib/providers/user_data_provider.dart
// ─────────────────────────────────────────────────────────────────────────────
// Central state manager.  Listens to Firebase Auth → auto-fetches Firestore.
// Uses real-time snapshots() so the UI updates the instant the Python backend
// writes new data after a resume analysis.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/roadmap_step.dart';
import '../models/project.dart';

class UserDataProvider extends ChangeNotifier {
  // ── Singletons ────────────────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;

  UserProfile _profile = UserProfile.empty;
  List<RoadmapStep> _roadmapSteps = [];
  List<Project> _projects = [];

  // ── Internal subscriptions ────────────────────────────────────────────────
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot>? _profileSub;
  StreamSubscription<DocumentSnapshot>? _roadmapSub;
  StreamSubscription<DocumentSnapshot>? _portfolioSub;

  // ── Public getters ────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfile get profile => _profile;
  List<RoadmapStep> get roadmapSteps => _roadmapSteps;
  List<Project> get projects => _projects;

  /// Convenience getters delegating to UserProfile
  String get targetCareer => _profile.targetCareer;
  int get profileScore => _profile.profileScore;
  List<String> get currentSkills => _profile.currentSkills;
  List<String> get missingSkills => _profile.missingSkills;

  /// Completed steps count (for the roadmap badge)
  int get completedSteps => _roadmapSteps.where((s) => s.isCompleted).length;

  /// Pending steps count
  int get pendingSteps => _roadmapSteps.where((s) => s.isPending).length;

  // ── Constructor: starts listening to auth state ───────────────────────────
  UserDataProvider() {
    _authSub = _auth.authStateChanges().listen(_onAuthChanged);
  }

  // ── Auth listener ─────────────────────────────────────────────────────────
  void _onAuthChanged(User? user) {
    if (user == null) {
      // User logged out → clear all data and cancel Firestore subscriptions
      _cancelFirestoreSubscriptions();
      _profile = UserProfile.empty;
      _roadmapSteps = [];
      _projects = [];
      _error = null;
      notifyListeners();
    } else {
      // User logged in → subscribe to their Firestore documents
      _subscribeToFirestore(user.uid);
    }
  }

  // ── Real-time Firestore subscriptions ─────────────────────────────────────
  void _subscribeToFirestore(String uid) {
    _setLoading(true);

    // ── profiles/{uid} ────────────────────────────────────────────────
    _profileSub = _db.collection('profiles').doc(uid).snapshots().listen(
      (snap) {
        if (snap.exists && snap.data() != null) {
          _profile = UserProfile.fromJson(snap.data()!, uid);
        } else {
          _profile = UserProfile.empty;
        }
        _setLoading(false);
      },
      onError: (e) {
        _error = 'Failed to load profile: $e';
        _setLoading(false);
      },
    );

    // ── roadmaps/{uid} ────────────────────────────────────────────────
    _roadmapSub = _db.collection('roadmaps').doc(uid).snapshots().listen(
      (snap) {
        if (snap.exists && snap.data() != null) {
          final data = snap.data()!;
          final rawSteps = data['steps'] as List<dynamic>? ?? [];
          _roadmapSteps = rawSteps
              .map((s) => RoadmapStep.fromJson(s as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.step.compareTo(b.step));
        } else {
          _roadmapSteps = [];
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Roadmap subscription error: $e');
      },
    );

    // ── portfolios/{uid} ──────────────────────────────────────────────
    _portfolioSub = _db.collection('portfolios').doc(uid).snapshots().listen(
      (snap) {
        if (snap.exists && snap.data() != null) {
          final data = snap.data()!;
          final rawProjects =
              data['recommended_projects'] as List<dynamic>? ?? [];
          _projects = rawProjects
              .map((p) => Project.fromJson(p as Map<String, dynamic>))
              .toList();
        } else {
          _projects = [];
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Portfolio subscription error: $e');
      },
    );
  }

  // ── Called after a successful resume upload ───────────────────────────────
  /// Since we're using real-time streams, the UI will update automatically
  /// when the Python backend writes to Firestore.  This method can be called
  /// to force an explicit refresh (e.g., for a pull-to-refresh gesture).
  Future<void> refresh() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _cancelFirestoreSubscriptions();
    _subscribeToFirestore(user.uid);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _cancelFirestoreSubscriptions() {
    _profileSub?.cancel();
    _roadmapSub?.cancel();
    _portfolioSub?.cancel();
    _profileSub = null;
    _roadmapSub = null;
    _portfolioSub = null;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _cancelFirestoreSubscriptions();
    super.dispose();
  }
}
