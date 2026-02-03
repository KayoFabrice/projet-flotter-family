class ContactActionTypes {
  const ContactActionTypes._();

  static const String writeAttempt = 'write_attempt';
  static const String writeSuccess = 'write_success';
  static const String callAttempt = 'call_attempt';
  static const String callSuccess = 'call_success';

  static bool isAttempt(String actionType) {
    return actionType.endsWith('_attempt');
  }
}
