import '../utils/constants.dart';
import 'auth_service.dart';
import 'data_service.dart';
import 'firebase/firebase_auth_service.dart';
import 'firebase/firestore_data_service.dart';
import 'local/local_auth_service.dart';
import 'local/local_data_service.dart';
import 'matching_service.dart';

/// The single place that decides which backend implementation the app uses.
///
/// Reading [AppConfig.useFirebase], it hands out either the Firebase-backed
/// services or the in-memory demo services. Everything else in the app depends
/// only on the abstract [AuthService] / [DataService], so flipping that one
/// flag swaps the entire backend with no other code changes.
class ServiceLocator {
  ServiceLocator._();
  static final ServiceLocator instance = ServiceLocator._();

  late final AuthService auth =
      AppConfig.useFirebase ? FirebaseAuthService() : LocalAuthService();

  late final DataService data =
      AppConfig.useFirebase ? FirestoreDataService() : LocalDataService();

  final MatchingService matching = const MatchingService();
}
