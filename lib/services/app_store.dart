import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';
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
  bool _signedIn = false;
  bool get signedIn => _signedIn;
  bool get hasProfile => preferences.containsKey('userProfile');
  Map<String, String> get _record {
    final raw = preferences.getString('userProfile');
    return raw == null ? {} : Map<String, String>.from(jsonDecode(raw) as Map);
  }

  bool get needsActivation => hasProfile && !_record.containsKey('_hash');
  Map<String, String> get profile => signedIn
      ? (_record
          ..remove('_hash')
          ..remove('_salt'))
      : {};

  void signOut() {
    _signedIn = false;
    notifyListeners();
  }

  Future<void> saveProfile(
    Map<String, String> values, {
    String? password,
  }) async {
    final record = _record;
    if (!signedIn && (hasProfile || password == null)) {
      throw StateError('Entre para alterar o cadastro.');
    }
    if (password != null) {
      if (password.length < 8) {
        throw ArgumentError('Use pelo menos 8 caracteres.');
      }
      final salt = List<int>.generate(16, (_) => _random.nextInt(256));
      record['_salt'] = base64Encode(salt);
      record['_hash'] = await compute(_derive, (password, record['_salt']!));
    }
    record.addAll(Map.of(values)..removeWhere((k, _) => k.startsWith('_')));
    await _writeAccount(record);
  }

  static final _random = Random.secure();
  static Future<String> _derive((String, String) input) async {
    final key =
        await Pbkdf2(
          macAlgorithm: Hmac.sha256(),
          iterations: 600000,
          bits: 256,
        ).deriveKey(
          secretKey: SecretKey(utf8.encode(input.$1)),
          nonce: base64Decode(input.$2),
        );
    return base64Encode(await key.extractBytes());
  }

  Future<void> _writeAccount(Map<String, String> record) async {
    if (!await preferences.setString('userProfile', jsonEncode(record))) {
      throw StateError('Não foi possível salvar o cadastro.');
    }
    _signedIn = true;
    notifyListeners();
  }

  Future<bool> signIn(
    String email,
    String password, {
    String? legacyCpf,
  }) async {
    final record = _record;
    if (record['email']?.trim().toLowerCase() != email.trim().toLowerCase()) {
      return false;
    }
    if (needsActivation) {
      final cpf = (legacyCpf ?? '').replaceAll(RegExp(r'\D'), '');
      if (cpf.length != 11 ||
          cpf != record['cpf']?.replaceAll(RegExp(r'\D'), '') ||
          password.length < 8) {
        return false;
      }
      record['_salt'] = base64Encode(
        List<int>.generate(16, (_) => _random.nextInt(256)),
      );
      record['_hash'] = await compute(_derive, (password, record['_salt']!));
      await _writeAccount(record);
      return true;
    }
    if (record['_salt'] == null) return false;
    final hash = await compute(_derive, (password, record['_salt']!));
    if (!constantTimeBytesEquality.equals(
      base64Decode(hash),
      base64Decode(record['_hash']!),
    )) {
      return false;
    }
    _signedIn = true;
    notifyListeners();
    return true;
  }

  List<Occurrence> get reports => List.unmodifiable(_reports);
  Future<void> add(Occurrence item) async {
    if (!signedIn) throw StateError('Entre para alterar ocorrências.');
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
    if (!signedIn) throw StateError('Entre para alterar ocorrências.');
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
