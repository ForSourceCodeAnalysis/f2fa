import 'package:equatable/equatable.dart';

class WebdavStatus extends Equatable {
  final String errorInfo;
  final bool configured;

  const WebdavStatus({this.errorInfo = '', this.configured = false});

  @override
  List<Object?> get props => [errorInfo, configured];

  WebdavStatus copyWith({String? errorInfo, bool? configured}) {
    return WebdavStatus(
      errorInfo: errorInfo ?? this.errorInfo,
      configured: configured ?? this.configured,
    );
  }
}
