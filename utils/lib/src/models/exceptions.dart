import 'package:quiver/strings.dart';

abstract class MessageException implements Exception {
  final String message;

  const MessageException(this.message);

  @override
  String toString() =>
      isNotBlank(message) ? '$runtimeType : $message' : super.toString();
}
