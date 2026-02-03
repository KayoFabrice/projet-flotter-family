import 'dart:math';

import '../../contacts/domain/contact_circle.dart';

enum MessageContext {
  general,
  morning,
  evening,
  weekend,
}

class MessageCatalog {
  const MessageCatalog(this._messages);

  final Map<ContactCircle, Map<MessageContext, List<String>>> _messages;

  static MessageCatalog defaultCatalog() {
    return const MessageCatalog(_defaultMessages);
  }

  List<String> messagesFor(
    ContactCircle circle, {
    MessageContext context = MessageContext.general,
  }) {
    final byContext = _messages[circle];
    if (byContext == null || byContext.isEmpty) {
      return const [];
    }

    final contextual = byContext[context];
    if (contextual != null && contextual.isNotEmpty) {
      return contextual;
    }

    return byContext[MessageContext.general] ?? const [];
  }

  String? selectMessage(
    ContactCircle circle, {
    MessageContext context = MessageContext.general,
    Random? random,
  }) {
    final candidates = messagesFor(circle, context: context);
    if (candidates.isEmpty) {
      return null;
    }

    final picker = random ?? Random();
    return candidates[picker.nextInt(candidates.length)];
  }
}

const Map<ContactCircle, Map<MessageContext, List<String>>> _defaultMessages = {
  ContactCircle.proches: {
    MessageContext.general: [
      'Un petit message pour prendre des nouvelles ?',
      'Tu veux saluer la famille aujourd\'hui ?',
      'C\'est un bon moment pour dire bonjour.',
    ],
    MessageContext.morning: [
      'Bon matin, envie d\'un mot doux ?',
      'Un coucou pour bien demarrer la journee ?',
    ],
    MessageContext.evening: [
      'Ce soir, un petit message ferait plaisir.',
      'Fin de journee parfaite pour un coucou.',
    ],
    MessageContext.weekend: [
      'Weekend calme, un mot a la famille ?',
      'Un petit salut pendant le weekend ?',
    ],
  },
  ContactCircle.eloignes: {
    MessageContext.general: [
      'Un petit message pour garder le lien ?',
      'Envie de prendre des nouvelles ?',
      'Un mot simple pour rester proche.',
    ],
    MessageContext.morning: [
      'Ce matin, un message rapide ferait plaisir.',
      'Un coucou leger pour commencer la journee.',
    ],
    MessageContext.evening: [
      'Ce soir, un petit mot sans pression ?',
      'Une pensee du soir a partager ?',
    ],
    MessageContext.weekend: [
      'Weekend tranquille, un message sympa ?',
      'Un petit lien pendant le weekend ?',
    ],
  },
  ContactCircle.partenaire: {
    MessageContext.general: [
      'Un mot tendre pour faire plaisir ?',
      'Un petit message pour dire que tu penses a eux.',
      'Un geste simple pour rester proches.',
    ],
    MessageContext.morning: [
      'Bon matin, un message doux ?',
      'Un coucou pour bien commencer la journee.',
    ],
    MessageContext.evening: [
      'Ce soir, un petit mot chaleureux ?',
      'Fin de journee, un message calme ?',
    ],
    MessageContext.weekend: [
      'Weekend, un petit message attentionne ?',
      'Un coucou pendant le weekend ?',
    ],
  },
  ContactCircle.amis: {
    MessageContext.general: [
      'Un petit message pour prendre des nouvelles ?',
      'Envie d\'un coucou rapide ?',
      'Un mot simple pour rester connectes.',
    ],
    MessageContext.morning: [
      'Bon matin, un message sympa ?',
      'Un coucou rapide ce matin ?',
    ],
    MessageContext.evening: [
      'Ce soir, un petit message cool ?',
      'Fin de journee, un coucou amical ?',
    ],
    MessageContext.weekend: [
      'Weekend, un petit message aux amis ?',
      'Un coucou du weekend ?',
    ],
  },
};
