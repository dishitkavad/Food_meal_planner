import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<String> uploadRecipeImage({
    required File imageFile,
    required String userId,
  }) async {
    final fileExtension =
    imageFile.path.split('.').last.toLowerCase();

    final fileName =
        '${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

    final filePath = fileName;

    await _supabase.storage
        .from('recipe-images')
        .upload(
      filePath,
      imageFile,
      fileOptions: const FileOptions(
        upsert: false,
      ),
    );

    final imageUrl = _supabase.storage
        .from('recipe-images')
        .getPublicUrl(filePath);

    return imageUrl;
  }
}