import 'dart:math';

import '../../contacts/domain/contact_circle.dart';
import '../domain/message_catalog.dart';

abstract class MessageCatalogRepository {
  MessageCatalog fetchCatalog();

  String? selectMessage({
    required ContactCircle circle,
    MessageContext context = MessageContext.general,
    Random? random,
  });
}

class MessageCatalogRepositoryImpl implements MessageCatalogRepository {
  MessageCatalogRepositoryImpl({MessageCatalog? catalog})
      : _catalog = catalog ?? MessageCatalog.defaultCatalog();

  final MessageCatalog _catalog;

  @override
  MessageCatalog fetchCatalog() {
    return _catalog;
  }

  @override
  String? selectMessage({
    required ContactCircle circle,
    MessageContext context = MessageContext.general,
    Random? random,
  }) {
    return _catalog.selectMessage(
      circle,
      context: context,
      random: random,
    );
  }
}
