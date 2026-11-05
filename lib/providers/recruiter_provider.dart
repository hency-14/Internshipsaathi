import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/application.dart';
import '../models/internship.dart';
import '../models/match_result.dart';
import '../models/recruiter.dart';
import '../models/student.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/matching_service.dart';
import '../services/service_locator.dart';
import '../utils/constants.dart';

/// One applicant to a posting, enriched with the student's profile and the
/// match score the engine gives them for that internship.
class Applicant {
  final Application application;
  final Student student;
  final MatchResult match;

  const Applicant({
    required this.application,
    required this.student,
    required this.match,
  });
}

/// Holds everything for a signed-in recruiter: company profile, postings (kept
/// **live** via a stream) and per-posting applicant counts. Load failures are
/// surfaced through [error] with a retry.
class RecruiterProvider extends ChangeNotifier {
  final DataService _data = ServiceLocator.instance.data;
  final MatchingService _matching = ServiceLocator.instance.matching;

  String? _uid;
  AuthUser? _user;
  Recruiter? _recruiter;
  List<Internship> _postings = <Internship>[];
  final Map<String, int> _applicantCounts = <String, int>{};
  bool _loading = false;
  String? _error;
  StreamSubscription<List<Internship>>? _postingsSub;

  Recruiter? get recruiter => _recruiter;
  List<Internship> get postings => _postings;
  bool get loading => _loading;
  String? get error => _error;
  bool get profileComplete => _recruiter?.isProfileComplete ?? false;

  int applicantCount(String internshipId) => _applicantCounts[internshipId] ?? 0;

  Future<void> onUserChanged(AuthUser? user, UserRole? role) async {
    if (user == null || role != UserRole.recruiter) {
      _uid = null;
      _user = null;
      _recruiter = null;
      _postings = <Internship>[];
      _applicantCounts.clear();
      _error = null;
      await _postingsSub?.cancel();
      _postingsSub = null;
      notifyListeners();
      return;
    }
    if (user.uid == _uid) return; // already loaded
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
      _recruiter = await _data.getRecruiter(user.uid) ??
          Recruiter(id: user.uid, name: user.displayName, email: user.email);
      _subscribePostings(user.uid);
    } catch (e) {
      _error = 'Could not load your data. Check your connection and retry.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _subscribePostings(String uid) {
    _postingsSub?.cancel();
    _postingsSub = _data.watchInternshipsByRecruiter(uid).listen(
      (List<Internship> list) async {
        _postings = list;
        await _refreshCounts();
        notifyListeners();
      },
      onError: (Object _) {/* keep last known postings */},
    );
  }

  Future<void> _refreshCounts() async {
    _applicantCounts.clear();
    for (final Internship i in _postings) {
      final List<Application> apps =
          await _data.getApplicationsForInternship(i.id);
      _applicantCounts[i.id] = apps.length;
    }
  }

  Future<void> retry() => _load();

  /// Pull-to-refresh: recompute applicant counts (postings themselves are live).
  Future<void> refresh() async {
    await _refreshCounts();
    notifyListeners();
  }

  Future<void> saveProfile(Recruiter updated) async {
    await _data.saveRecruiter(updated);
    _recruiter = updated;
    notifyListeners();
  }

  /// Creates or updates a posting. The recruiter's id and company name are
  /// stamped here. New postings get a generated id and the current timestamp.
  /// The live postings stream reflects the change automatically.
  Future<void> savePosting(Internship draft) async {
    final String? uid = _uid;
    final Recruiter? r = _recruiter;
    if (uid == null || r == null) return;

    final bool isNew = draft.id.isEmpty;
    final Internship toSave = Internship(
      id: isNew
          ? 'intern-$uid-${DateTime.now().millisecondsSinceEpoch}'
          : draft.id,
      title: draft.title,
      company: r.companyName,
      location: draft.location,
      workMode: draft.workMode,
      stipend: draft.stipend,
      durationMonths: draft.durationMonths,
      description: draft.description,
      requiredSkills: draft.requiredSkills,
      domains: draft.domains,
      careerTracks: draft.careerTracks,
      postedAt: isNew ? DateTime.now() : draft.postedAt,
      recruiterId: uid,
    );
    await _data.postInternship(toSave);
  }

  Future<void> deletePosting(String internshipId) async {
    await _data.deleteInternship(internshipId);
  }

  /// Live stream of a posting's applicants, each enriched with their profile
  /// and match score, best match first. Updates as students apply or statuses
  /// change.
  Stream<List<Applicant>> applicantsStream(Internship internship) {
    return _data
        .watchApplicationsForInternship(internship.id)
        .asyncMap((List<Application> apps) async {
      final List<Applicant> result = <Applicant>[];
      for (final Application a in apps) {
        final Student? s = await _data.getStudent(a.studentId);
        if (s == null) continue;
        result.add(Applicant(
          application: a,
          student: s,
          match: _matching.score(s, internship),
        ));
      }
      result.sort((Applicant x, Applicant y) =>
          y.match.score.compareTo(x.match.score));
      return result;
    });
  }

  Future<void> setApplicationStatus(
      Application application, ApplicationStatus status) async {
    await _data.updateApplicationStatus(application.id, status);
  }

  @override
  void dispose() {
    _postingsSub?.cancel();
    super.dispose();
  }
}
