import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserRepository {
  static const String _boxName = 'user_data';

  // Mendapatkan box
  Future<Box<UserModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<UserModel>(_boxName);
    }
    return await Hive.openBox<UserModel>(_boxName);
  }

  // Simpan user
  Future<void> saveUser(UserModel user) async {
    final box = await _getBox();
    await box.put('user', user);
  }

  // Ambil user
  Future<UserModel?> getUser() async {
    final box = await _getBox();
    return box.get('user');
  }

  // Update user
  Future<void> updateUser(UserModel Function(UserModel) update) async {
    final box = await _getBox();
    final currentUser = box.get('user');

    if (currentUser != null) {
      final updatedUser = update(currentUser);
      await box.put('user', updatedUser);
    }
  }

  // Hapus user (reset)
  Future<void> deleteUser() async {
    final box = await _getBox();
    await box.delete('user');
  }
}
