# Story 2.1: Voir ses proches par categories avec recherche simple

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a utilisateur occupe,
I want voir rapidement mes proches par categorie et les retrouver via recherche,
so that je garde le controle sans effort.

## Acceptance Criteria

1. Given l'utilisateur ouvre l'onglet Proches, When des proches existent, Then ils sont affiches par categorie avec un regroupement clair, And un champ de recherche permet de filtrer instantanement par nom.
2. Given aucun proche n'existe, When l'utilisateur ouvre Proches, Then un etat vide chaleureux est affiche, And un CTA principal propose d'ajouter un proche.

## Tasks / Subtasks

- [x] Construire l'ecran Proches (liste par categories) conforme aux maquettes hi-fi (AC: 1, 2)
  - [x] Ajouter un champ de recherche en tete
  - [x] Afficher les sections par categorie (Proches/Eloignes/Partenaire/Amis)
  - [x] Ajouter un etat vide avec CTA "Ajouter un proche"
- [x] Recherche simple instantanee (AC: 1)
  - [x] Filtrer par nom (case-insensitive)
  - [x] Mettre a jour la liste sans rechargement complet
- [x] State management Riverpod (AC: 1, 2)
  - [x] Provider `contactsProvider` (AsyncValue) pour liste + filtre
  - [x] Debouncer simple pour saisie (si necessaire)
- [x] Persistance et recuperation (AC: 1)
  - [x] Reutiliser repository/service contacts existants (ne pas dupliquer)
  - [x] Ajouter une methode de recherche locale (SQL LIKE ou filtre in-memory)
- [x] Navigation vers ajout (AC: 2)
  - [x] CTA etat vide -> ecran ajout contact (story 2.2)
- [x] Tests essentiels (AC: 1, 2)
  - [x] Test widget: affichage sections + recherche
  - [x] Test recherche: filtre par nom
  - [x] Test etat vide + CTA

## Dev Notes

- Contexte: onglet "Proches" (tab bottom nav). Liste par categorie + recherche simple.
- UX: aligner avec `contacts.png` (hi-fi). Ton chaleureux, minimal.
- Donnees: utiliser les contacts locaux (SQLite). Pas d'API reseau au MVP.
- Flux impose: UI -> Provider -> Service -> Repository -> DB. Aucun acces DB direct depuis UI.
- Erreurs: afficher un message neutre si echec de chargement.

### Developer Context (Guardrails)

- Feature-first strict: `features/contacts/{data,domain,presentation}`.
- Providers suffixes `Provider`, UI lit des `AsyncValue`.
- Bottom nav canonique inchangee: Agenda / Proches / Reglages.

### Technical Requirements

- Flutter SDK stable, Dart stable.
- Riverpod (flutter_riverpod) + AsyncValue.
- SQLite via `sqflite` + `path`.
- Pas de backend cloud au MVP.

### Architecture Compliance

- Tables en `snake_case` pluriel, colonnes en `snake_case`.
- Logique metier dans `domain/`, persistence dans `data/`, UI dans `presentation/`.
- UI composee via cards/sections reutilisables.

### File Structure Requirements

- UI: `lib/features/contacts/presentation/pages/contacts_page.dart`
- Widgets: `lib/features/contacts/presentation/widgets/contact_list_item.dart`
- Provider: `lib/features/contacts/presentation/providers/contacts_provider.dart`
- Domaine: `lib/features/contacts/domain/contact.dart`
- Service: `lib/features/contacts/domain/contacts_service.dart`
- Repository: `lib/features/contacts/data/contacts_repository.dart`

### Testing Requirements

- Widget test: sections + recherche.
- Provider/service test: chargement et filtre.
- Test etat vide + CTA.

### Previous Story Intelligence

- Les stories 1.x ont etabli les modeles contacts et la persistance locale. Reutiliser les tables existantes.
- Conserver le pattern `AsyncValue.guard` + SnackBar d'erreur.

### Git Intelligence Summary

- L'infra contacts et onboarding existe deja. Eviter les doublons de repository.
- Eviter les styles hardcodes non alignes au theme global.

### Latest Tech Information (verifier versions exactes avant implementation)

- Verifier les versions Flutter/Dart au moment de l'implementation.

### Project Context Reference

- Suivre strictement `_bmad-output/project-context.md`.

## References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 2.1: Voir ses proches par categories avec recherche simple]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Linked Screens (Hi-Fi)]
- [Source: _bmad-output/planning-artifacts/architecture.md#Implementation Patterns & Consistency Rules]
- [Source: _bmad-output/project-context.md#Critical Implementation Rules]

## Dev Agent Record

### Agent Model Used

GPT-5 Codex (Scrum Master Bob)

### Debug Log References

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Status set to ready-for-dev.
- ContactsPage conforme maquette (header, recherche, sections par categorie, carte sync) + etat vide avec CTA.
- Provider contactsProvider (AsyncValue) avec debouncer et filtrage case-insensitive sans reload complet.
- Repository/service enrichis (chargement + recherche locale), navigation CTA vers ecran ajout (placeholder).
- Tests ajoutes: widget (sections/recherche, etat vide), provider (filtre), service (chargement/recherche). `flutter test` OK.
- Code review fixes: ecran ajout fonctionnel (creation contact), SnackBar erreur garde, couleurs alignees theme, debounce plus robuste, tests complets recherche + creation contact. `flutter test` OK.

### File List

- _bmad-output/implementation-artifacts/2-1-voir-ses-proches-par-categories-avec-recherche-simple.md
- _bmad-output/implementation-artifacts/sprint-status.yaml
- lib/core/navigation/app_shell.dart
- lib/main.dart
- lib/features/contacts/data/contacts_repository.dart
- lib/features/contacts/domain/contacts_service.dart
- lib/features/contacts/presentation/pages/contact_edit_page.dart
- lib/features/contacts/presentation/pages/contacts_page.dart
- lib/features/contacts/presentation/widgets/contact_list_item.dart
- lib/features/contacts/presentation/providers/contacts_provider.dart
- test/features/contacts/domain/contacts_import_service_test.dart
- test/features/contacts/domain/contacts_service_test.dart
- test/features/contacts/presentation/circles_page_test.dart
- test/features/contacts/presentation/contacts_page_test.dart
- test/features/contacts/presentation/first_contacts_navigation_test.dart
- test/features/contacts/presentation/providers/contacts_import_provider_test.dart
- test/features/contacts/presentation/providers/contacts_provider_test.dart
- test/features/contacts/presentation/providers/onboarding_contacts_provider_test.dart
- .flutter-plugins-dependencies
- android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java
- ios/Pods/Pods.xcodeproj/project.pbxproj
- ios/Pods/Pods.xcodeproj/xcuserdata/fabricekayo.xcuserdatad/xcschemes/xcschememanagement.plist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-acknowledgements.markdown
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-acknowledgements.plist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-input-files.xcfilelist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Debug-output-files.xcfilelist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Profile-input-files.xcfilelist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Profile-output-files.xcfilelist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-input-files.xcfilelist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks-Release-output-files.xcfilelist
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner-frameworks.sh
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig
- ios/Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig
- ios/Pods/Target Support Files/Pods-RunnerTests/Pods-RunnerTests.debug.xcconfig
- ios/Pods/Target Support Files/Pods-RunnerTests/Pods-RunnerTests.profile.xcconfig
- ios/Pods/Target Support Files/Pods-RunnerTests/Pods-RunnerTests.release.xcconfig
- ios/Runner.xcodeproj/project.pbxproj
- ios/Runner.xcworkspace/xcuserdata/fabricekayo.xcuserdatad/UserInterfaceState.xcuserstate
- ios/Runner/GeneratedPluginRegistrant.m
- windows/flutter/generated_plugin_registrant.cc
- windows/flutter/generated_plugins.cmake

### Change Log

- 2026-01-30: ecran Proches (sections + recherche + etat vide + navigation) + provider/debouncer + repo recherche + tests.
- 2026-01-30: correctifs code review (ajout contact fonctionnel, guard SnackBar, couleurs theme, tests recherche/creation).
