---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - /Users/fabricekayo/Desktop/projet_flutter_famille/_bmad-output/planning-artifacts/prd.md
  - /Users/fabricekayo/Desktop/projet_flutter_famille/_bmad-output/planning-artifacts/product-brief-projet_flutter_famille-2026-01-12.md
  - /Users/fabricekayo/Desktop/projet_flutter_famille/_bmad-output/planning-artifacts/ux-design-specification.md
  - /Users/fabricekayo/Desktop/projet_flutter_famille/_bmad-output/planning-artifacts/prd-validation-report.md
workflowType: 'architecture'
project_name: 'projet_flutter_famille'
user_name: 'Fabricekayo'
date: '2026-01-27T15:35:59+01:00'
lastStep: 8
status: 'complete'
completedAt: '2026-01-27T16:06:55+01:00'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**
Le cœur produit repose sur des rappels contextuels transformables en action immédiate (Écrire/Appeler) avec un minimum d’étapes. L’architecture devra clairement séparer : gestion des relations/cadences, moteur de contexte & timing (fenêtres, cooldown, “pas le bon moment”), orchestration des notifications, et mise à jour fiable de l’historique.

**Non-Functional Requirements:**
Les exigences les plus structurantes sont : fiabilité des rappels (95% dans la fenêtre), performance perçue (p95), confidentialité (données locales chiffrées, pas de tracking), accessibilité (WCAG AA), et robustesse offline partielle.

**Scale & Complexity:**
Complexité globale : faible à modérée, mais avec quelques zones “piégeuses” (permissions background, notifications, contexte, offline).

- Primary domain: mobile_app (Flutter iOS/Android)
- Complexity level: low-to-medium
- Estimated architectural components: ~6–8 blocs majeurs (UI agenda, relations, cadences, contexte/timing, notifications, historique, permissions, storage)

### Technical Constraints & Dependencies

Contraintes clés : permissions mobiles sensibles, exécution fiable en arrière-plan, notifications locales actionnables, et cohérence entre mode contextuel et mode dégradé.

### Cross-Cutting Concerns Identified

Préoccupations transverses : gestion fine des permissions, confidentialité/stockage local, fiabilité du moteur de rappel, observabilité minimale (fiabilité & p95), et cohérence UX (ton, friction minimale, fallback propre).

## Starter Template Evaluation

### Primary Technology Domain

Mobile Flutter (iOS/Android), avec Firebase comme backend futur.

### Starter Options Considered

- Flutter standard (`flutter create`) + FlutterFire CLI (officiel, simple, évolutif)
- Stacks plus “opinionated” écartées pour garder un socle stable et minimal

### Selected Starter: Flutter standard + FlutterFire CLI

**Rationale for Selection:**
Socle officiel, stable, et compatible avec une montée progressive vers Firebase cloud, tout en gardant une base locale au début.

**Initialization Command:**

```bash
flutter create projet_flutter_famille
firebase login
dart pub global activate flutterfire_cli
flutterfire configure
```

Ces commandes suivent les parcours officiels Flutter et Firebase pour l’initialisation et la configuration FlutterFire.

**Architectural Decisions Provided by Starter:**

**Language & Runtime:**
Dart + Flutter stable, via l’outil CLI Flutter officiel.

**Styling Solution:**
Material Design (Flutter) comme base pragmatique et cohérente avec votre spec UX.

**Build Tooling:**
Tooling Flutter natif (`flutter` CLI) pour créer, tester, analyser et builder.

**Testing Framework:**
Flutter test natif, intégré au CLI Flutter.

**Code Organization:**
Structure Flutter standard, facile à maintenir et à faire évoluer.

**Development Experience:**
Hot reload + outillage Flutter officiel, avec configuration Firebase via FlutterFire CLI.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Données locales via SQLite avec `sqflite`.
- Pas d’authentification au MVP.
- State management via Riverpod.
- Notifications locales uniquement au MVP.

**Important Decisions (Shape Architecture):**
- Préparer une couche “sync” abstraite pour Firebase plus tard.
- Séparer clairement : moteur de rappel, stockage, permissions, UI.

**Deferred Decisions (Post-MVP):**
- Auth Firebase.
- Sync cloud (Firestore).
- Analytics avancées.

### Data Architecture

- Stockage local : SQLite via `sqflite`.
- Stratégie : schéma simple + migrations versionnées.
- Validation : côté domaine (avant persistance).
- Source de vérité MVP : la base locale.

### Authentication & Security

- Auth : aucune au MVP.
- Sécurité : données locales uniquement, surface réseau minimale.
- Prévoir des interfaces pour brancher Firebase Auth plus tard.

### API & Communication Patterns

- Aucune API réseau au MVP (tout local).
- Contrats internes : services + repositories.

### Frontend Architecture

- State management : Riverpod.
- Architecture UI : features modulaires (agenda, contacts, réglages, rappels).
- Navigation : simple, centrée sur l’agenda.

### Infrastructure & Deployment

- Cible : iOS/Android (stores uniquement).
- Backend cloud : explicitement hors MVP.

### Decision Impact Analysis

**Implementation Sequence:**
- Mettre en place la base locale (`sqflite`) et les modèles.
- Structurer les repositories/services autour du local-first.
- Implémenter le moteur de rappels + notifications locales.
- Connecter l’UI agenda aux flux Riverpod.

**Cross-Component Dependencies:**
- Le moteur de rappels dépend du stockage (cadence, historique) et des permissions.
- L’UI dépend des repositories et de la logique de rappel, pas de la persistance directe.

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:**
Navigation, structure par feature, composants cards/sections, formats dates, et patterns Riverpod.

### Naming Patterns

**Database Naming Conventions (SQLite / sqflite):**
- Tables en `snake_case` pluriel : `contacts`, `reminders`, `contact_history`
- Colonnes en `snake_case` : `contact_id`, `last_contact_at`, `next_suggested_at`
- PK : `id` (INTEGER)
- FK : `<entity>_id`

**Code Naming Conventions (Flutter/Dart):**
- Fichiers : `snake_case.dart`
- Classes : `PascalCase`
- Variables/fonctions : `camelCase`
- Providers Riverpod : suffixe `Provider`

### Structure Patterns

**Project Organization (feature-first):**
- `features/agenda/`
- `features/contacts/`
- `features/settings/`
- `features/reminders/`

Chaque feature contient :
- `data/` (db, dto, repositories)
- `domain/` (models, services, rules)
- `presentation/` (pages, widgets, providers)

**Core transverses :**
- `core/database/`
- `core/navigation/`
- `core/theme/`
- `core/notifications/`

### UI Composition Patterns (aligné hi-fi)

**Navigation (obligatoire) :**
- Bottom nav fixe : `Agenda / Proches / Réglages`
- Les écrans racines correspondent 1:1 aux tabs

**Agenda (obligatoire) :**
- Sections temporelles réutilisables : `Aujourd’hui / Cette semaine / Ce mois`
- `SuggestionCard` en haut quand disponible
- Cartes contact homogènes avec CTAs (`Écrire`, `Appeler`, `Relancer`, `Plus tard`)

**Contacts :**
- Liste + recherche simple
- Zone “contacts sélectionnés”
- Bloc CTA “Synchroniser vos contacts”

**Détail contact :**
- Header profil
- Actions primaires côte à côte : `Écrire / Appeler`
- Bloc métriques (dernier contact, cadence, prochain)
- Historique récent en liste

### Format Patterns

**Dates & temps :**
- Stockage : ISO 8601 UTC
- Affichage : relatif ou court (ex: “il y a 3 semaines”)

### Communication Patterns (Riverpod)

**Flux obligatoire :**
UI → Provider → Service → Repository → DB

Règles :
- UI ne touche jamais la DB
- Providers exposent `AsyncValue`
- Les règles métier vivent en `domain/`

### Process Patterns

**Loading :**
- `AsyncValue` partout côté écrans
- États vides explicites avec 1 CTA principal

**Errors :**
- Erreurs techniques loggées
- Messages utilisateur courts et neutres

### Enforcement Guidelines

**All AI Agents MUST:**
- Respecter la bottom nav canonique
- Composer l’UI via cards/sections réutilisables
- Respecter le flux UI → Provider → Service → Repository → DB
- Ne jamais accéder à la DB depuis la UI

### Pattern Examples

**Good:**
- `agenda_section.dart`
- `suggestion_card.dart`
- `contact_metrics_card.dart`
- `fetch_due_reminders_provider.dart`

**Anti-patterns:**
- UI qui appelle `database.insert(...)`
- Écrans roots qui ne correspondent pas aux tabs

## Project Structure & Boundaries

### Complete Project Directory Structure

```text
projet_flutter_famille/
├── README.md
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
├── assets/
│   ├── icons/
│   ├── images/
│   └── fonts/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── migrations.dart
│   │   │   └── tables/
│   │   │       ├── contacts_table.dart
│   │   │       ├── reminders_table.dart
│   │   │       └── contact_history_table.dart
│   │   ├── navigation/
│   │   │   ├── app_router.dart
│   │   │   └── bottom_nav_shell.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_typography.dart
│   │   ├── notifications/
│   │   │   ├── local_notifications_service.dart
│   │   │   └── notification_channels.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   └── result.dart
│   │   └── widgets/
│   │       ├── app_scaffold.dart
│   │       └── section_header.dart
│   ├── features/
│   │   ├── agenda/
│   │   │   ├── data/
│   │   │   │   ├── agenda_repository.dart
│   │   │   │   └── agenda_queries.dart
│   │   │   ├── domain/
│   │   │   │   ├── agenda_item.dart
│   │   │   │   └── compute_due_contacts.dart
│   │   │   └── presentation/
│   │   │       ├── agenda_page.dart
│   │   │       ├── providers/
│   │   │       │   ├── agenda_provider.dart
│   │   │       │   └── suggestion_provider.dart
│   │   │       └── widgets/
│   │   │           ├── agenda_section.dart
│   │   │           ├── suggestion_card.dart
│   │   │           └── agenda_contact_card.dart
│   │   ├── contacts/
│   │   │   ├── data/
│   │   │   │   ├── contacts_repository.dart
│   │   │   │   └── contacts_local_data_source.dart
│   │   │   ├── domain/
│   │   │   │   ├── contact.dart
│   │   │   │   └── contact_cadence.dart
│   │   │   └── presentation/
│   │   │       ├── contacts_page.dart
│   │   │       ├── contact_detail_page.dart
│   │   │       ├── contact_edit_page.dart
│   │   │       ├── providers/
│   │   │       │   ├── contacts_provider.dart
│   │   │       │   └── contact_detail_provider.dart
│   │   │       └── widgets/
│   │   │           ├── contact_list_item.dart
│   │   │           ├── contact_metrics_card.dart
│   │   │           └── cadence_chips.dart
│   │   ├── reminders/
│   │   │   ├── data/
│   │   │   │   ├── reminders_repository.dart
│   │   │   │   └── reminders_scheduler.dart
│   │   │   ├── domain/
│   │   │   │   ├── reminder.dart
│   │   │   │   └── reminder_rules.dart
│   │   │   └── presentation/
│   │   │       └── providers/
│   │   │           ├── due_reminders_provider.dart
│   │   │           └── reminders_settings_provider.dart
│   │   └── settings/
│   │       ├── data/
│   │       │   └── settings_repository.dart
│   │       ├── domain/
│   │       │   ├── settings.dart
│   │       │   └── reminder_windows.dart
│   │       └── presentation/
│   │           ├── settings_page.dart
│   │           ├── providers/
│   │           │   └── settings_provider.dart
│   │           └── widgets/
│   │               ├── settings_tile.dart
│   │               └── permissions_tile.dart
│   └── l10n/
│       ├── app_fr.arb
│       └── l10n.dart
└── test/
    ├── core/
    └── features/
```

### Architectural Boundaries

**Component Boundaries:**
- UI dépend uniquement des providers et services de domaine.
- Les repositories encapsulent tout accès `sqflite`.
- La navigation racine est limitée au shell bottom nav.

**Data Boundaries:**
- SQLite est la source de vérité MVP.
- Les règles métier s’exécutent avant persistance.

### Requirements to Structure Mapping

**FR Category → Structure:**
- Onboarding & Setup → `features/contacts/` + `features/settings/`
- Contacts & Relations → `features/contacts/`
- Contexte & Timing → `features/reminders/domain/`
- Rappels & Notifications → `core/notifications/` + `features/reminders/`
- Historique & Suivi → `features/agenda/` + `contact_history_table.dart`
- Permissions & Mode Dégradé → `features/settings/` + `core/notifications/`
- Offline → structure local-first (repositories + SQLite)
- Paramétrage → `features/settings/`
- Valeur & Expérience → `features/agenda/presentation/`

### Integration Points

**Internal Communication:**
- UI → Provider → Service → Repository → Database

**External Integrations:**
- MVP : aucune intégration cloud obligatoire.
- Futur : Firebase via une couche sync dédiée (non MVP).

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
- Les décisions sont cohérentes entre elles : Flutter + local-first, sans auth, avec `sqflite` et Riverpod.
- Les patterns UI (bottom nav, cards, sections) sont alignés avec les écrans hi-fi.

**Pattern Consistency:**
- Les règles (feature-first, UI → Provider → Service → Repository → DB) sont compatibles avec Riverpod et `sqflite`.
- Les conventions de nommage et de structure sont stables pour plusieurs agents.

**Structure Alignment:**
- La structure proposée reflète directement les patterns définis.
- Les frontières (UI vs data, core vs features) sont explicites.

### Requirements Coverage Validation ✅

**Functional Requirements Coverage:**
- Onboarding/contacts/settings/reminders/agenda sont tous mappés à des modules dédiés.
- Les points sensibles (permissions, mode dégradé, offline) sont couverts par une architecture local-first.

**Non-Functional Requirements Coverage:**
- Performance : local-first limite la latence perçue.
- Fiabilité : moteur de rappels + stockage local.
- Confidentialité : pas d’API réseau au MVP.
- Accessibilité : compatible avec Material + règles UX existantes.

### Implementation Readiness Validation ✅

**Decision Completeness:**
- Les décisions critiques MVP sont prises : stockage, état, notifications, auth.

**Structure Completeness:**
- La structure est suffisamment concrète pour guider l’implémentation sans ambiguïté majeure.

**Pattern Completeness:**
- Les principales zones de divergence entre agents sont cadrées (noms, structure, flux, UI).

### Gap Analysis Results

**Important Gaps (non bloquants) :**
- Spécifier plus tard le schéma SQLite exact (tables + indices).
- Définir les contrats d’interface pour la future sync Firebase.
- Détails précis de scheduling background selon iOS/Android.

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Contexte analysé
- [x] Contraintes identifiées
- [x] Complexité évaluée

**✅ Architectural Decisions**
- [x] Décisions critiques prises
- [x] Approche local-first claire
- [x] Alignement UX hi-fi assuré

**✅ Implementation Patterns**
- [x] Règles de nommage définies
- [x] Règles de structure définies
- [x] Flux d’implémentation imposé

**✅ Project Structure**
- [x] Arborescence complète définie
- [x] Frontières explicites
- [x] Mapping FR → structure effectué

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION (MVP local-first)

**Confidence Level:** High pour un MVP local-only

**Key Strengths:**
- Simplicité volontaire (local-first, pas d’auth)
- Structure claire pour éviter les conflits d’agents
- Fort alignement avec la spec UX et les hi-fi

**Areas for Future Enhancement:**
- Sync Firebase (Firestore + auth)
- Observabilité plus détaillée
- Optimisations background multi-plateforme

### Implementation Handoff

**AI Agent Guidelines:**
- Suivre strictement le flux UI → Provider → Service → Repository → DB
- Respecter la structure feature-first et la bottom nav canonique
- Ne jamais court-circuiter les repositories

**First Implementation Priority:**
- Mettre en place la base `sqflite`, les repositories, et le shell de navigation.

## Architecture Completion Summary

### Workflow Completion

**Architecture Decision Workflow:** COMPLETED ✅  
**Total Steps Completed:** 8  
**Date Completed:** 2026-01-27T16:06:55+01:00  
**Document Location:** `_bmad-output/planning-artifacts/architecture.md`

### Final Architecture Deliverables

- Architecture complète (décisions, patterns, structure, validation)
- Règles de cohérence pour agents IA
- Structure projet Flutter local-first alignée UX hi-fi

### Implementation Handoff

**First Implementation Priority:**  
Mettre en place `sqflite`, les repositories, et le shell bottom nav.
