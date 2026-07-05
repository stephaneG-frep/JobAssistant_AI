import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/local_database_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._database);

  final LocalDatabaseService _database;
  UserProfile profile = UserProfile();

  void load() {
    final data = _database.getProfile();
    profile = data == null ? UserProfile() : UserProfile.fromJson(data);
    notifyListeners();
  }

  Future<void> save(UserProfile nextProfile) async {
    profile = nextProfile;
    await _database.saveProfile(profile.toJson());
    notifyListeners();
  }
}
