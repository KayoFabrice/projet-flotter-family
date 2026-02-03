import 'package:url_launcher/url_launcher.dart';

import 'contact.dart';
import 'contact_history_service.dart';

class ContactWriteOption {
  const ContactWriteOption({
    required this.label,
    required this.uri,
  });

  final String label;
  final Uri uri;
}

enum ContactWriteOutcome {
  success,
  unavailable,
  failed,
}

abstract class ContactActionLauncher {
  Future<bool> canLaunch(Uri uri);
  Future<bool> launch(Uri uri);
}

class UrlLauncherContactActionLauncher implements ContactActionLauncher {
  @override
  Future<bool> canLaunch(Uri uri) {
    return canLaunchUrl(uri);
  }

  @override
  Future<bool> launch(Uri uri) {
    return launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }
}

class ContactWriteActionService {
  ContactWriteActionService({
    required ContactHistoryService historyService,
    required ContactActionLauncher launcher,
  })  : _historyService = historyService,
        _launcher = launcher;

  final ContactHistoryService _historyService;
  final ContactActionLauncher _launcher;

  List<ContactWriteOption> buildWriteOptions(Contact contact) {
    final options = <ContactWriteOption>[];
    final phone = contact.phone?.trim();
    final email = contact.email?.trim();
    if (phone != null && phone.isNotEmpty) {
      options.add(
        ContactWriteOption(
          label: 'Ecrire par SMS',
          uri: Uri(scheme: 'sms', path: phone),
        ),
      );
    }
    if (email != null && email.isNotEmpty) {
      options.add(
        ContactWriteOption(
          label: 'Ecrire par email',
          uri: Uri(scheme: 'mailto', path: email),
        ),
      );
    }
    return options;
  }

  Future<ContactWriteOutcome> launchWrite({
    required String contactId,
    required Uri uri,
  }) async {
    await _historyService.recordWriteAttempt(contactId: contactId);
    final canLaunch = await _launcher.canLaunch(uri);
    if (!canLaunch) {
      return ContactWriteOutcome.unavailable;
    }
    final success = await _launcher.launch(uri);
    if (!success) {
      return ContactWriteOutcome.failed;
    }
    await _historyService.recordWriteSuccess(contactId: contactId);
    return ContactWriteOutcome.success;
  }
}
