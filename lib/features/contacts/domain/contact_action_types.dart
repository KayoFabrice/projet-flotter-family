class ContactActionTypes {
  const ContactActionTypes._();

  static const String writeAttempt = 'write_attempt';
  static const String writeSuccess = 'write_success';

  static bool isAttempt(String actionType) {
    return actionType.endsWith('_attempt');
  }
}
