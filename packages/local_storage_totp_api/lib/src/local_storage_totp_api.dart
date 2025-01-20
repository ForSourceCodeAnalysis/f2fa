import 'dart:convert';
import 'package:local_storage_repository/local_storage_repository.dart';
import 'package:totp_api/totp_api.dart';
import 'package:otp/otp.dart';

class LocalStorageTotpApi extends TotpApi {
  LocalStorageTotpApi._();

  static final LocalStorageTotpApi _instance = LocalStorageTotpApi._();
  static bool isInitialized = false;
  static const String _storageKey = 'totpliststr';
  static late final LocalStorageRepository _localStorageRepository;

  static List<Totp> _totps = [];

  static Future<LocalStorageTotpApi> getInstance() async {
    if (!isInitialized) {
      _localStorageRepository = await LocalStorageRepository.getInstance();
      isInitialized = true;
      _loadData();
    }
    return _instance;
  }

  static void _loadData() {
    final totpsJson = _localStorageRepository.box.get(_storageKey);
    if (totpsJson != null) {
      parseFromJson(totpsJson);
    }
  }

  static void parseFromJson(String json) {
    _totps = List<Map<String, dynamic>>.from(
      jsonDecode(json),
    ).map((el) => Totp.fromJson(el)).toList();
  }

  @override
  Future<List<Totp>> getTotpList() => Future.value(_totps);

  @override
  Future<void> saveTotp(Totp totp) async {
    final totps = [..._totps];
    final index = totps.indexWhere((i) => i.id == totp.id);
    if (index >= 0) {
      totps[index] = totp;
    } else {
      totps.add(totp);
    }

    _totps = totps;
    _localStorageRepository.box.put(_storageKey, jsonEncode(_totps));
  }

  @override
  Future<void> deleteTotp(String id) async {
    final totps = [..._totps];
    final index = totps.indexWhere((totp) => totp.id == id);
    if (index < 0) {
      return;
    }
    totps.removeAt(index);
    _totps = totps;
    return _localStorageRepository.box.put(_storageKey, jsonEncode(_totps));
  }

  @override
  List<Totp> refreshCode() {
    return _totps.map((t) {
      final code = OTP.generateTOTPCodeString(
        t.secret,
        DateTime.now().millisecondsSinceEpoch,
        interval: t.period,
        length: t.digits,
        algorithm: Algorithm.values.byName(t.algorithm.toUpperCase()),
        isGoogle: true,
      );
      final remaining = OTP.remainingSeconds();

      return t.copyWith(
        remaining: remaining,
        code: code,
      );
    }).toList();
  }

  @override
  Future<void> reorderTotps(List<Totp> totps) async {
    _totps = totps;
    await _localStorageRepository.box.put(_storageKey, jsonEncode(_totps));
  }

  Future<void> updateData(String totps) async {
    parseFromJson(totps);
    await _localStorageRepository.box.put(_storageKey, totps);
  }
}
