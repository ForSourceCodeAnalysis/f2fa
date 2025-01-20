import 'package:totp_api/src/models/totp.dart';

/// {@template totp_api}
/// The interface for an Api that provides options to a list of totp.
/// {@endtemplate}
///
abstract class TotpApi {
  /// {@macro totp_api}
  const TotpApi();

  /// Get the list of totp for a given account
  ///
  /// Returns a [List] of [Totp]
  Future<List<Totp>> getTotpList();

  /// Saves a given totp
  ///
  /// If a totp with the same issuer and account already exists, it will be overwritten
  Future<void> saveTotp(Totp totp);

  /// Delete a totp with the given id
  ///
  /// If no totp with the given id exists, nothing will happen
  Future<void> deleteTotp(String id);

  /// Refresh the code of all totp
  List<Totp> refreshCode();

  /// Reorder the totp list
  ///
  /// Accepts a [List] of [Totp] in the new order and saves it
  Future<void> reorderTotps(List<Totp> totps);
}
