---
project_name: 'projet_flutter_famille'
user_name: 'Fabricekayo'
date: '2026-01-27T16:25:37+01:00'
sections_completed:
  [
    'technology_stack',
    'language_rules',
    'framework_rules',
    'testing_rules',
    'quality_rules',
    'workflow_rules',
    'anti_patterns',
  ]
existing_patterns_found: 0
status: 'complete'
rule_count: 40
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

- Flutter (SDK stable)
- Dart (via Flutter SDK)
- Local DB: SQLite via `sqflite`
- State management: Riverpod
- Notifications: locales uniquement (MVP)
- Backend cloud: aucun au MVP (Firebase plus tard)

## Critical Implementation Rules

### Language-Specific Rules (Dart)

- Fichiers en `snake_case.dart`
- Classes en `PascalCase`, variables/fonctions en `camelCase`
- Types explicites sur les modèles et retours de services (éviter `dynamic`)
- Dates stockées en ISO 8601 UTC (`toIso8601String()`), conversion pour l’affichage uniquement
- Pas d’accès DB direct hors repositories
- Async/await uniquement (éviter les `.then(...)` en cascade)

### Framework-Specific Rules (Flutter + Riverpod)

- Flux obligatoire : UI → Provider → Service → Repository → DB
- UI ne touche jamais la DB ni `sqflite` directement
- Providers suffixés `Provider`
- Écrans racines = tabs bottom nav : `Agenda / Proches / Réglages`
- Organisation feature-first stricte : `features/<feature>/{data,domain,presentation}`
- UI composée via sections/cards réutilisables (aligné hi-fi)
- Utiliser `AsyncValue` pour les états `loading/data/error`

### Testing Rules

- Priorité : tests unitaires domaine (`domain/`) et règles de rappel
- Tester les providers Riverpod critiques (cas `loading/data/error`)
- Éviter les tests UI fragiles tant que l’UI bouge beaucoup
- Toute logique de date/cadence doit être testée
- Un bug corrigé ⇒ ajouter un test ciblé

### Code Quality & Style Rules

- Logique métier interdite dans `presentation/`
- Services = règles métier, repositories = accès données
- Pas de “god files” : préférer petits fichiers lisibles
- Ajouter un commentaire court uniquement si la règle métier n’est pas évidente
- Respect strict des noms/structure définis dans l’architecture

### Development Workflow Rules

- Toute implémentation commence par lire :
  - `_bmad-output/planning-artifacts/architecture.md`
  - `_bmad-output/planning-artifacts/ux-design-specification.md`
- En cas de conflit : l’architecture fait foi, puis la spec UX
- Ne pas introduire Firebase cloud tant que ce n’est pas explicitement demandé
- Toute nouvelle feature doit se ranger dans une feature existante ou en créer une propre
- Si une décision architecture manque : l’ajouter d’abord, puis coder

### Critical Don’t-Miss Rules

- INTERDIT : accès `sqflite` depuis l’UI
- INTERDIT : logique de cadence/rappel dans `presentation/`
- INTERDIT : changer la bottom nav canonique (`Agenda / Proches / Réglages`)
- INTERDIT : ajouter Firebase cloud au MVP sans décision explicite
- OBLIGATOIRE : dates stockées en ISO UTC, formatage uniquement pour affichage
- OBLIGATOIRE : respecter la structure feature-first et les noms de composants clés (agenda sections, cards)

---

## Usage Guidelines

**For AI Agents:**
- Lire ce fichier avant toute implémentation
- Suivre toutes les règles, même si une autre approche “marche”
- En cas de doute : choisir l’option la plus restrictive et cohérente avec l’architecture
- Mettre à jour ce fichier si une nouvelle règle récurrente apparaît

**For Humans:**
- Garder ce fichier court et orienté “anti-erreurs”
- Mettre à jour quand la stack ou les patterns changent
- Supprimer les règles devenues évidentes

Last Updated: 2026-01-27T16:25:37+01:00
