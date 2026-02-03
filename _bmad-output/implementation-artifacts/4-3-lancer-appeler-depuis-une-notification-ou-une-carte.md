# Story 4.3: Lancer "Appeler" depuis une notification ou une carte

Status: done

## Story

As a utilisateur,
I want lancer l'action Appeler en un tap,
so that je contacte rapidement un proche important.

## Acceptance Criteria

1. Given un rappel contextuel est emis, When l'utilisateur choisit "Appeler", Then l'application ouvre l'intention d'appel appropriee, And l'action est tracee comme tentative de contact.
2. Given l'action Appeler est declenchee, When elle est consideree comme reussie par l'application, Then l'historique du proche est mis a jour avec une date ISO UTC, And la suggestion associee disparait ou se met a jour proprement.

## Tasks / Subtasks

- [x] Action "Appeler" depuis UI et notification
- [x] Trace + update historique
- [x] Tests unitaires sur service d'historique

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.3: Lancer "Appeler" depuis une notification ou une carte]

## Dev Agent Record

### Implementation Plan
- Ajouter un service d'appel avec historisation tentative/succes.
- Brancher l'action Appeler depuis la SuggestionCard et la notification.
- Ajouter les tests unitaires du service d'historique pour l'appel.

### Debug Log
- RAS.

### Completion Notes
- Action Appeler branchee depuis l'agenda (tel:) avec feedback et invalidation de suggestion apres succes.
- Handler notification Appeler ajoute avec historisation tentative/succes en ISO UTC.
- Historique affiche l'appel sortant pour les entrees call_success.
- Parser de payload notification ajoute pour gerer Appeler via route arguments.
- Test unitaire ajoute pour handleCallAction.

### Tests
- `flutter test`

## File List
- lib/core/navigation/app_shell.dart
- lib/features/contacts/domain/contact_action_types.dart
- lib/features/contacts/domain/contact_call_action_service.dart
- lib/features/contacts/domain/contact_history_service.dart
- lib/features/contacts/presentation/pages/contact_detail_page.dart
- lib/features/contacts/presentation/providers/contact_action_provider.dart
- lib/features/reminders/domain/notification_action_handler.dart
- lib/features/reminders/domain/notification_action_payload.dart
- lib/features/reminders/presentation/providers/notification_action_provider.dart
- test/features/contacts/domain/contact_history_service_test.dart
- test/features/reminders/domain/notification_action_handler_test.dart
- ios/Runner.xcworkspace/xcuserdata/fabricekayo.xcuserdatad/UserInterfaceState.xcuserstate

## Change Log
- 2026-02-03: Ajout action Appeler (UI + notification), historisation, tests.
- 2026-02-03: Revue code - parser notification Appeler + test handler.
