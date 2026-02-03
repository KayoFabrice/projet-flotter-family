# Story 4.2: Lancer "Ecrire" depuis une notification ou une carte

Status: review

## Story

As a utilisateur,
I want lancer l'action Ecrire en un tap,
so that je transforme un rappel en action immediate.

## Acceptance Criteria

1. Given un rappel contextuel est emis, When l'utilisateur choisit "Ecrire" depuis la notification ou la SuggestionCard, Then l'application ouvre le canal d'ecriture prevu, And l'action est tracee comme tentative de contact.
2. Given l'action Ecrire est declenchee, When elle est consideree comme reussie par l'application, Then l'historique du proche est mis a jour avec une date ISO UTC, And la prochaine suggestion respecte la cadence et le cooldown.

## Tasks / Subtasks

- [x] Action "Ecrire" depuis UI et notification
- [x] Trace de tentative + mise a jour historique
- [x] Tests unitaires sur service d'historique

## Dev Notes

- Utiliser intents natifs pour messages.
- Historique via repository/service.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.2: Lancer "Ecrire" depuis une notification ou une carte]

## Dev Agent Record

### Implementation Plan
- Ajouter un service d'historique avec enregistrement ISO UTC.
- Brancher l'action Ecrire depuis la SuggestionCard via intents natifs.
- Exposer un handler pour notifications et couvrir le service d'historique en tests unitaires.

### Debug Log
- RAS.

### Completion Notes
- Action Ecrire connectee a l'agenda: ouverture SMS/mail avec gestion multi-options et feedback utilisateur.
- Tentative + succes historises via ContactHistoryService et repository.
- Handler notification ajoute pour reutiliser la meme logique.
- Tests: service d'historique + suite complete.

### Tests
- `flutter test test/features/contacts/domain/contact_history_service_test.dart`
- `flutter test`

## File List
- lib/core/navigation/app_shell.dart
- lib/features/contacts/data/contact_history_repository.dart
- lib/features/contacts/domain/contact_action_types.dart
- lib/features/contacts/domain/contact_history_service.dart
- lib/features/contacts/domain/contact_write_action_service.dart
- lib/features/contacts/presentation/providers/contact_action_provider.dart
- lib/features/reminders/domain/notification_action_handler.dart
- lib/features/reminders/presentation/providers/notification_action_provider.dart
- test/features/contacts/domain/contact_history_service_test.dart
- test/features/contacts/presentation/contact_edit_page_test.dart
- test/features/contacts/presentation/providers/contact_detail_provider_test.dart
- test/features/reminders/domain/reminder_suggestion_service_test.dart

## Change Log
- 2026-02-03: Ajout action Ecrire (UI + notification handler), historisation et tests.
