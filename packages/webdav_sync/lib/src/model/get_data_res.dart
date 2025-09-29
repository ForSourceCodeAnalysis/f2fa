import 'package:local_storage_repository/local_storage_repository.dart';

enum GetDataStatus { notModified, created, modified, empty }

class GetDataRes {
  final List<Totp>? data;

  final GetDataStatus status;

  GetDataRes({this.data, this.status = GetDataStatus.modified});
}
