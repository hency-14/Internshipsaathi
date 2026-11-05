import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/application.dart';
import '../models/internship.dart';
import '../models/match_result.dart';
import '../models/student.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/matching_service.dart';
import '../services/service_locator.dart';
import '../utils/constants.dart';

/// Holds everything tied to the signed-in student: profile, internship
/// catalog, ranked matches and applications. The applications list is kept
/// **live** via a stream, so status changes a recruiter makes appear here
/// without a reload. Load failures are surfaced through [error] with a retry.
class SessionProvider extends ChangeNotifier {
  final DataService _data = ServiceLocator.instance.data;
  final MatchingService _matching = ServiceLocator.instance.matching;

  String? _uid;
  AuthUser? _user;
  Student? _student;
  List<Internship> _internships = <Internship>[];
  List<MatchResult> _matches = <MatchResult>[];
  List<Application> _applications = <Application>[];
  bool _loading = false;
  String? _error;
  StreamSubscription<List<Application>>? _appsSub;

  Student? get student => _student;
  List<Internship> get internships => _internships;
  List<MatchResult> get matches => _matches;
  List<Application> get applications => _applications;
  bool get loading => _loading;
  String? get error => _error;

  bool get profileComplete => _student?.isProfileComplete ?? false;

  Set<String> get appliedInternshipIds =>
      _applications.map((Application a) => a.internshipId).toSet();

  bool hasApplied(String internshipId) =>
      appliedInternshipIds.contains(internshipId);

  /// Called by the proxy provider when auth state changes. Loads data for a
  /// student, or clears it for sign-out / recruiters.
  Future<void> onUserChanged(AuthUser? user, UserRole? role) async {
    if (user == null || role != UserRole.student) {
      _uid = null;
      _user = null;
      _student = null;
      _internships = <Internship>[];
      _matches = <MatchResult>[];
      _applications = <Application>[];
      _error = null;
      await _appsSub?.cancel();
      _appsSub = null;
      notifyListeners();
      return;
    }
    if (user.uid == _uid) return; // already loaded for this user
    _uid = user.uid;
    _user = user;
    await _load();
  }

  Future<void> _load() async {
    final AuthUser? user = _user;
    if (user == null) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _student = await _data.getStudent(user.uid) ??
          Student(id: user.uid, name: user.displayName, email: user.email);
      _internships = await _data.getInternships();
      _recomputeMatches();
      _subscribeApplications(user.uid);
    } catch (e) {
      _error = 'Could not load your data. Check your connection and retry.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _subscribeApplications(String uid) {
    _appsSub?.cancel();
    _appsSub = _data.watchApplications(uid).listen(
      (List<Application> apps) {
        _applications = apps;
        notifyListeners();
      },
      onError: (Object _) {/* keep last known list on transient errors */},
    );
  }

  /// Retries loading after an error (used by the retry button).
  Future<void> retry() => _load();

  /// Pull-to-refresh: re-fetches the profile and catalog so newly posted
  /// internships show up. Applications stay live via the stream.
  Future<void> refresh() async {
    final AuthUser? user = _user;
    if (user == null) return;
    try {
      _student = await _data.getStudent(user.uid) ?? _student;
      _internships = await _data.getInternships();
      _recomputeMatches();
      _error = null;
    } catch (e) {
      _error = 'Refresh failed. Please try again.';
    }
    notifyListeners();
  }

  /// Persists an updated profile and re-ranks matches against it.
  Future<void> saveProfile(Student updated) async {
    await _data.saveStudent(updated);
    _student = updated;
    _recomputeMatches();
    notifyListeners();
  }

  /// Records an application. The live stream updates [applications].
  Future<void> apply(Internship internship) async {
    final Student? s = _student;
    if (s == null) return;
    final Application application = Application(
      id: 'app-${s.id}-${internship.id}',
      studentId: s.id,
      internshipId: internship.id,
      status: ApplicationStatus.applied,
      appliedAt: DateTime.now(),
    );
    await _data.apply(application);
  }

  /// Pushes the bundled sample internships to the backend (used once to seed
  /// an empty Firestore from the app). Then reloads the catalog.
  Future<void> seedCatalog() async {
    await _data.seedInternships(SeedData.internships());
    _internships = await _data.getInternships();
    _recomputeMatches();
    notifyListeners();
  }

  void _recomputeMatches() {
    final Student? s = _student;
    if (s == null || !s.isProfileComplete) {
      _matches = <MatchResult>[];
      return;
    }
    _matches = _matching.rank(s, _internships);
  }

  Internship? internshipById(String id) {
    for (final Internship i in _internships) {
      if (i.id == id) return i;
    }
    return null;
  }

  MatchResult matchFor(Internship internship) {
    final Student? s = _student;
    if (s == null) {
      return MatchResult(
        internship: internship,
        score: 0,
        breakdown: const <MatchDimension, double>{},
        matchedSkills: const <String>[],
      );
    }
    return _matching.score(s, internship);
  }

  @override
  void dispose() {
    _appsSub?.cancel();
    super.dispose();
  }
}
