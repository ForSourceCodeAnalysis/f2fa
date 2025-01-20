import 'package:flutter_test/flutter_test.dart';

import 'package:totp_api/totp_api.dart';

void main() {
  group('Totp', () {
    test('fromJson returns a valid Totp object', () {
      final json = {
        'issuer': 'test_issuer',
        'account': 'test_account',
        'secret': 'test_secret',
        'type': 'totp',
        'algorithm': 'sha1',
        'digits': 6,
        'period': 30,
      };
      final totp = Totp.fromJson(json);
      expect(totp.issuer, 'test_issuer');
      expect(totp.account, 'test_account');
      expect(totp.secret, 'test_secret');
      expect(totp.type, 'totp');
      expect(totp.algorithm, 'sha1');
      expect(totp.digits, 6);
      expect(totp.period, 30);
    });

    test('toJson returns a valid JSON object', () {
      final totp = Totp(
        issuer: 'test_issuer',
        account: 'test_account',
        secret: 'test_secret',
        type: 'totp',
        algorithm: 'sha1',
        digits: 6,
        period: 30,
      );
      final json = totp.toJson();
      expect(json, {
        'issuer': 'test_issuer',
        'account': 'test_account',
        'secret': 'test_secret',
        'type': 'totp',
        'algorithm': 'sha1',
        'digits': 6,
        'period': 30,
      });
    });

    test('toJson not include code and remaining', () {
      final totp = Totp(
        issuer: 'test_issuer',
        account: 'test_account',
        secret: 'test_secret',
        type: 'totp',
        algorithm: 'sha1',
        digits: 6,
        period: 30,
      );
      expect(totp.code, '');
      expect(totp.remaining, 0);

      final json = totp.toJson();
      expect(json, {
        'issuer': 'test_issuer',
        'account': 'test_account',
        'secret': 'test_secret',
        'type': 'totp',
        'algorithm': 'sha1',
        'digits': 6,
        'period': 30,
      });
    });

    test('fromJson not include code and remaining', () {
      final json = {
        'issuer': 'test_issuer',
        'account': 'test_account',
        'secret': 'test_secret',
        'type': 'totp',
        'algorithm': 'sha1',
        'digits': 6,
        'period': 30,
        'code': 'aond',
        'remaining': 7,
      };
      final totp = Totp.fromJson(json);
      expect(totp.code, '');
      expect(totp.remaining, 0);
    });

    test('equality works correctly', () {
      final totp1 = Totp(
        issuer: 'test_issuer',
        account: 'test_account',
        secret: 'test_secret',
        type: 'totp',
        algorithm: 'sha1',
        digits: 6,
        period: 30,
      );
      final totp2 = Totp(
        issuer: 'test_issuer',
        account: 'test_account',
        secret: 'test_secret',
        type: 'totp',
        algorithm: 'sha1',
        digits: 6,
        period: 30,
      );
      expect(totp1, totp2);
    });

    test('hashCode works correctly', () {
      final totp1 = Totp(
        issuer: 'test_issuer',
        account: 'test_account',
        secret: 'test_secret',
        type: 'totp',
        algorithm: 'sha1',
        digits: 6,
        period: 30,
      );
      final totp2 = Totp(
        issuer: 'test_issuer',
        account: 'test_account',
        secret: 'test_secret',
        type: 'totp',
        algorithm: 'sha1',
        digits: 6,
        period: 30,
      );
      expect(totp1.hashCode, totp2.hashCode);
    });
  });
}
