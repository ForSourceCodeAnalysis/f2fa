import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:totp_api/totp_api.dart';
import 'package:totp_repository/src/totp_repository.dart';

class MockTotpApi extends Mock implements TotpApi {}

void main() {
  late MockTotpApi mockTotpApi;
  late TotpRepository totpRepository;

  group('TotpRepository', () {
    setUp(() {
      mockTotpApi = MockTotpApi();
      when(() => mockTotpApi.getTotpList()).thenAnswer((_) async => []);

      totpRepository = TotpRepository(totpApi: mockTotpApi);
    });
    test('initializes with empty TOTP list', () async {
      expectLater(totpRepository.getTotps(), emits([]));

      verify(() => mockTotpApi.getTotpList()).called(1);
    });

    test('saves a new TOTP and updates the stream', () async {
      final totp = Totp(
        issuer: 'example.com',
        account: 'user@example.com',
        secret: 'secret123',
      );

      when(() => mockTotpApi.saveTotp(totp)).thenAnswer((_) async => {});
      when(() => mockTotpApi.getTotpList()).thenAnswer((_) async => [totp]);

      await totpRepository.saveTotp(totp);

      expectLater(totpRepository.getTotps(), emits([totp]));

      verify(() => mockTotpApi.saveTotp(totp)).called(1);
      verify(() => mockTotpApi.getTotpList()).called(2);
    });

    test('save a new TOTP fail, do not update the stream', () async {
      final totp = Totp(
        issuer: 'example.com',
        account: 'user@example.com',
        secret: 'secret123',
      );

      when(() => mockTotpApi.saveTotp(totp))
          .thenAnswer((_) => throw Exception('error'));
      when(() => mockTotpApi.getTotpList()).thenAnswer((_) async => []);

      expectLater(() => totpRepository.saveTotp(totp), throwsException);

      expectLater(totpRepository.getTotps(), emits([]));
    });

    test('deletes a TOTP and updates the stream', () async {
      final totp = Totp(
        issuer: 'example.com',
        account: 'user@example.com',
        secret: 'secret123',
      );

      when(() => mockTotpApi.deleteTotp(totp.id)).thenAnswer((_) async => true);
      when(() => mockTotpApi.getTotpList()).thenAnswer((_) async => []);

      await totpRepository.deleteTotp(totp.id);

      expectLater(totpRepository.getTotps(), emits([]));

      verify(() => mockTotpApi.deleteTotp(totp.id)).called(1);
      verify(() => mockTotpApi.getTotpList()).called(2);
    });
  });
}
