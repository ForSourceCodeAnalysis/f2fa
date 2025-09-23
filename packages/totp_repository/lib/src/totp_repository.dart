import 'package:rxdart/rxdart.dart';
import 'package:totp_api/totp_api.dart';

class TotpRepository {
  TotpRepository({
    required TotpApi totpApi,
  }) : _totpApi = totpApi {
    _init();
  }

  TotpApi _totpApi;

  late final _todoStreamController =
      BehaviorSubject<List<Totp>>.seeded(const []);

  Future<void> _init() async {
    final tps = await _totpApi.getTotpList();
    _todoStreamController.add(tps);
  }

  Stream<List<Totp>> getTotps() => _todoStreamController.asBroadcastStream();

  Future<void> saveTotp(Totp totp) async {
    await _totpApi.saveTotp(totp);

    _todoStreamController.add(await _totpApi.getTotpList());
  }

  Future<void> deleteTotp(String id) async {
    await _totpApi.deleteTotp(id);

    _todoStreamController.add(await _totpApi.getTotpList());
  }

  Future<void> tickerUpdateCode() async {
    _totpApi.refreshCode();
    _todoStreamController.add(await _totpApi.getTotpList());
  }

  Future<void> reorderTotps(List<Totp> totps) async {
    await _totpApi.reorderTotps(totps);
    _todoStreamController.add(totps);
  }

  Future<void> changeApi(TotpApi api) async {
    _totpApi = api;
    _todoStreamController.add(await _totpApi.getTotpList());
  }

  void dispose() {
    _todoStreamController.close();
  }
}
