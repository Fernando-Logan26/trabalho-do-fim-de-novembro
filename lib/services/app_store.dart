import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/occurrence.dart';

/// Persistência do protótipo, sem servidor e sem transmissão de ocorrências.
class AppStore extends ChangeNotifier {
  final SharedPreferences preferences;
  final List<Occurrence> _reports = [];
  bool largeText = false, highContrast = false, welcomed = false;
  String mobility = 'Pessoa com mobilidade reduzida';
  AppStore(this.preferences) {
    largeText = preferences.getBool('largeText') ?? false;
    highContrast = preferences.getBool('highContrast') ?? false;
    welcomed = preferences.getBool('welcomed') ?? false;
    mobility = preferences.getString('mobility') ?? mobility;
    final raw = preferences.getString('occurrences');
    if (raw != null) {
      try {
        for (final item in jsonDecode(raw) as List) {
          _reports.add(
            Occurrence.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        }
      } catch (_) {
        /* Preserva o arquivo original caso não possa ser lido. */
      }
    }
  }
  List<Occurrence> get reports => List.unmodifiable(_reports);
  Future<void> add(Occurrence item) async {
    final next = [item, ..._reports];
    if (!await preferences.setString(
      'occurrences',
      jsonEncode(next.map((e) => e.toJson()).toList()),
    )) {
      throw StateError('Não foi possível salvar a ocorrência.');
    }
    _reports.insert(0, item);
    notifyListeners();
  }

  Future<void> remove(Occurrence item) async {
    final next = _reports.where((e) => e.id != item.id).toList();
    if (!await preferences.setString(
      'occurrences',
      jsonEncode(next.map((e) => e.toJson()).toList()),
    )) {
      throw StateError('Não foi possível excluir a ocorrência.');
    }
    _reports.removeWhere((e) => e.id == item.id);
    if (item.photoPath != null) {
      try {
        await File(item.photoPath!).delete();
      } catch (_) {}
    }
    notifyListeners();
  }

  Future<void> setWelcome() async {
    await preferences.setBool('welcomed', true);
    welcomed = true;
    notifyListeners();
  }

  Future<void> setAccessibility({
    bool? large,
    bool? contrast,
    String? profile,
  }) async {
    if (large != null) {
      largeText = large;
      await preferences.setBool('largeText', large);
    }
    if (contrast != null) {
      highContrast = contrast;
      await preferences.setBool('highContrast', contrast);
    }
    if (profile != null) {
      mobility = profile;
      await preferences.setString('mobility', profile);
    }
    notifyListeners();
  }
}
