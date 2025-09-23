import 'package:totp_api/totp_api.dart';

enum GetDataStatus { notModified, created, modified, empty }

class GetDataRes {
  final List<Totp>? data;

  final GetDataStatus status;

  GetDataRes({this.data, this.status = GetDataStatus.modified});
}
