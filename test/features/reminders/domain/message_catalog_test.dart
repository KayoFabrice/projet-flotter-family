import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/reminders/domain/message_catalog.dart';

void main() {
  group('MessageCatalog', () {
    test('provides short messages per category', () {
      final catalog = MessageCatalog.defaultCatalog();

      const contexts = MessageContext.values;
      for (final circle in ContactCircle.values) {
        for (final context in contexts) {
          final messages = catalog.messagesFor(circle, context: context);
          expect(messages, isNotEmpty);
          for (final message in messages) {
            expect(message.length, lessThanOrEqualTo(80));
          }
        }
      }
    });

    test('returns context variants when available', () {
      final catalog = MessageCatalog.defaultCatalog();

      final morningMessages = catalog.messagesFor(
        ContactCircle.proches,
        context: MessageContext.morning,
      );
      final generalMessages = catalog.messagesFor(ContactCircle.proches);

      expect(morningMessages, isNotEmpty);
      expect(morningMessages, isNot(generalMessages));
    });

    test('falls back to general messages when context missing', () {
      final catalog = MessageCatalog(
        const {
          ContactCircle.amis: {
            MessageContext.general: ['Salut !'],
          },
        },
      );

      final fallback = catalog.messagesFor(
        ContactCircle.amis,
        context: MessageContext.evening,
      );

      expect(fallback, ['Salut !']);
    });

    test('selects deterministically with seeded random', () {
      final catalog = MessageCatalog.defaultCatalog();

      final firstPick = catalog.selectMessage(
        ContactCircle.eloignes,
        context: MessageContext.general,
        random: Random(42),
      );
      final secondPick = catalog.selectMessage(
        ContactCircle.eloignes,
        context: MessageContext.general,
        random: Random(42),
      );

      expect(firstPick, isNotNull);
      expect(firstPick, equals(secondPick));
    });

    test('never returns a message outside the catalog', () {
      final catalog = MessageCatalog.defaultCatalog();

      final selected = catalog.selectMessage(
        ContactCircle.partenaire,
        context: MessageContext.weekend,
        random: Random(7),
      );

      final allowed = catalog.messagesFor(
        ContactCircle.partenaire,
        context: MessageContext.weekend,
      );

      expect(selected, isNotNull);
      expect(allowed, contains(selected));
    });
  });
}
