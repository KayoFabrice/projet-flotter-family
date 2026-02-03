# Story 4.1: Afficher une suggestion claire dans l'Agenda

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur,
I want voir une suggestion prioritaire dans l'Agenda,
so that je puisse agir rapidement sans chercher.

## Acceptance Criteria

1. Given une suggestion est disponible, When l'utilisateur ouvre l'onglet Agenda, Then une SuggestionCard est affichee en haut de section, And elle propose des actions explicites (Ecrire, Appeler, Plus tard).
2. Given aucune suggestion n'est disponible, When l'utilisateur ouvre l'Agenda, Then l'ecran reste utile avec ses sections temporelles, And aucun espace vide trompeur n'apparait.

## Tasks / Subtasks

- [x] Ajouter `SuggestionCard` en haut de l'agenda (AC: 1)
- [x] Gerer l'etat sans suggestion (AC: 2)
- [x] Wire avec provider de suggestion (AC: 1)
- [x] Tests widget essentiels (AC: 1, 2)

## Dev Notes

- Contexte: UI Agenda. Respecter cards/sections reutilisables.
- Actions: Ecrire/Appeler/Plus tard visibles.

### File Structure Requirements

- UI: `lib/features/agenda/presentation/widgets/suggestion_card.dart`
- Provider: `lib/features/agenda/presentation/providers/suggestion_provider.dart`

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.1: Afficher une suggestion claire dans l'Agenda]
- [Source: _bmad-output/planning-artifacts/architecture.md#UI Composition Patterns]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Component Strategy]

## Dev Agent Record

### Agent Model Used

GPT-5 Codex (Scrum Master Bob)

### Debug Log References

- N/A

### Implementation Plan

- Ajouter une SuggestionCard reutilisable avec actions visibles.
- Brancher la suggestion depuis le provider agenda dans l'onglet Agenda.
- Afficher les sections temporelles par defaut si aucune suggestion.
- Couvrir l'affichage avec tests widget.

### Completion Notes List

- SuggestionCard ajoutee avec actions Ecrire / Appeler / Plus tard.
- Agenda affiche les sections Aujourd'hui / Cette semaine / Ce mois meme sans suggestion.
- Provider de suggestion deplace dans `features/agenda` et branche dans AppShell.
- Tests: `flutter test test/features/agenda/presentation/agenda_suggestion_test.dart`, `flutter test`.
- 2026-02-03: code review fixes — actions wirees (snackbar), sections Agenda alignees UX, `AgendaSection` extrait, tests mis a jour.

### File List

- _bmad-output/implementation-artifacts/4-1-afficher-une-suggestion-claire-dans-l-agenda.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- lib/core/navigation/app_shell.dart
- lib/features/agenda/presentation/providers/suggestion_provider.dart
- lib/features/agenda/presentation/widgets/agenda_section.dart
- lib/features/agenda/presentation/widgets/suggestion_card.dart
- lib/features/reminders/presentation/providers/suggestion_provider.dart
- test/features/agenda/presentation/agenda_suggestion_test.dart

## Change Log

- 2026-02-03: ajout SuggestionCard agenda + sections temporelles + tests widget.
- 2026-02-03: corrections code review (actions, sections Agenda, widget reutilisable, tests).
