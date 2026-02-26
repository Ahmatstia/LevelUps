import 'package:hive/hive.dart';
import '../models/tag_model.dart';

class TagRepository {
  static const String _boxName = 'tags';

  Future<Box<TagModel>> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box<TagModel>(_boxName);
    }
    return await Hive.openBox<TagModel>(_boxName);
  }

  Future<void> addTag(TagModel tag) async {
    final box = await _getBox();
    await box.put(tag.id, tag);
  }

  Future<List<TagModel>> getAllTags() async {
    final box = await _getBox();
    return box.values.toList();
  }

  Future<TagModel?> getTag(String id) async {
    final box = await _getBox();
    return box.get(id);
  }

  Future<void> updateTag(TagModel tag) async {
    final box = await _getBox();
    await box.put(tag.id, tag);
  }

  Future<void> deleteTag(String tagId) async {
    final box = await _getBox();
    await box.delete(tagId);
  }
}
