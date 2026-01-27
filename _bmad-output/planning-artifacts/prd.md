---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-03-success
  - step-04-journeys
  - step-05-domain
  - step-06-innovation
  - step-07-project-type
  - step-08-scoping
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
inputDocuments:
  - /Users/fabricekayo/Desktop/projet_flutter_famille/_bmad-output/planning-artifacts/product-brief-projet_flutter_famille-2026-01-12.md
  - /Users/fabricekayo/Desktop/projet_flutter_famille/_bmad-output/analysis/brainstorming-session-2026-01-12-020645.md
documentCounts:
  briefCount: 1
  researchCount: 0
  brainstormingCount: 1
  projectDocsCount: 0
workflowType: 'prd'
date: 2026-01-12T04:04:24+01:00
classification:
  projectType: mobile_app
  domain: general
  complexity: low
  projectContext: greenfield
---

# Product Requirements Document - projet_flutter_famille

**Author:** Fabricekayo
**Date:** 2026-01-12T04:04:24+01:00

## Executive Summary

Application mobile iOS/Android qui aide les personnes occupees a garder un contact regulier avec leur famille. Le produit envoie des rappels discrets et contextuels (lieu + moment) et propose une action en un tap (ecrire/appeler) avec un ton chaleureux et non culpabilisant.

Differenciateurs clefs : rappels contextuels plutot que fixes, cadence par groupes de relations, notification actionnable, experience minimaliste.

Probleme/impact : l'oubli des contacts cree des reproches et un eloignement relationnel, avec un sentiment de culpabilite cote utilisateur.

## Project Classification

- Type: mobile_app (Flutter, iOS/Android)
- Domaine: general (grand public)
- Complexite: low
- Contexte: greenfield

## Success Criteria

### User Success

- Chaque utilisateur realise 2-3 contacts par mois avec sa famille.
- Le "moment aha" est atteint apres 2 semaines consecutives avec >= 1 contact/semaine.
- A 30 jours, l'utilisateur recoit des rappels utiles et contacte activement ses proches.

### Business Success

- 3 mois : >= 300 utilisateurs actifs, 40% de retention a 4 semaines.
- 12 mois : >= 5 000 MAU, WAU/MAU >= 50%.
- Croissance organique et engagement comme priorite, monetisation non prioritaire.

### Technical Success

- Notifications contextuelles fiables et discretes.
- Latence minimale et consommation d'energie maitrisee (pas d'impact perceptible au quotidien).

### Measurable Outcomes

- >= 50% des utilisateurs contactent au moins 1 proche/semaine.
- >= 30% des notifications declenchent "Ecrire" ou "Appeler".
- >= 40% de retention a 4 semaines.
- Taux de rappels "au bon moment" percu comme utile dans > 70% des retours.

## Product Scope

### MVP - Minimum Viable Product

- Categories de proches (proches / eloignes / partenaire / amis)
- Lieux cles (maison, travail, entrainement)
- Rappels contextuels discrets
- Notification actionnable en 1 tap (Ecrire / Appeler)
- Historique leger "dernier contact : X jours"
- Cadence par categorie (proche = 1 semaine, eloigne = 1 mois)

### Growth Features (Post-MVP)

- Recommandations de messages plus personnalisees
- Contexte enrichi (calendrier, habitudes, focus)
- Tableau de bord relationnel minimal
- Cadences partageables entre membres de la famille

### Vision (Future)

- Rituels relationnels (anniversaires, moments cles)
- Contexte ultra-enrichi et intelligence de timing avancee

## User Journeys

### Journey 1 - Utilisateur principal (happy path)

On rencontre Alex, 26 ans, actif entre travail et activites. Il tient a garder le lien familial mais n'a aucun rythme fixe : les jours passent, il oublie d'ecrire.

Il installe l'app, classe ses proches, autorise la localisation. Au fil des semaines, les rappels arrivent quand il est disponible.

Le moment cle : un soir, apres le travail, une notif discrete lui propose "Ecrire" a sa mere. Il repond en 10 secondes. Peu a peu, il reprend un rythme regulier sans culpabilite. Son sentiment : "Je suis a jour sans effort."

### Journey 2 - Utilisateur principal (edge case : permissions refusees)

Alex installe l'app mais refuse la localisation (fatigue, mefiance). Les rappels deviennent moins pertinents. Il en ignore plusieurs, l'app perd sa valeur.

L'app explique clairement ce qu'elle perd sans la permission et propose un mode minimal (rappels non contextuels, horaires manuels). Le moment critique : Alex accepte la permission apres avoir vu un rappel trop intrusif. Le service redevient utile.

### Journey 3 - Self-service sans support

Alex n'a aucun support humain. Tout doit etre simple et clair : onboarding, reglages, et comprehension du "bon moment". Quand il veut modifier ses categories ou la cadence, il doit pouvoir le faire en 2-3 taps, sans friction.

### Journey Requirements Summary

- Onboarding ultra-simple avec categorisation et explication des permissions.
- Rappels contextualises "au bon moment".
- Actions 1-tap (Ecrire/Appeler) directement depuis notification.
- Mode degrade si permissions refusees + explication claire de l'impact.
- Reglages self-service rapides (cadence, categories).
- Ton chaleureux et non culpabilisant.

## Mobile App Specific Requirements

### Project-Type Overview

Application mobile cross-platform (Flutter) iOS/Android, orientee rappels contextuels familiaux, sans support tablette.

### Technical Architecture Considerations

- Notifications locales avec fenetres horaires (pas de rappel la nuit).
- Mode offline : rappels locaux possibles, mais pas d'envoi de messages/appels sans reseau.
- Gestion stricte des permissions pour garantir la pertinence du contexte.

### Platform Requirements

- Support iOS + Android (Flutter).
- Pas de support tablette.

### Device Permissions

- Localisation en arriere-plan.
- Acces contacts.
- Calendrier.
- Appels/SMS (actions rapides).

### Store Compliance

- Pas de tracking.
- Pas de publicite.
- Gestion des licences.

### Offline Mode

- Rappels/notifications locales OK.
- Envoi de messages/appels uniquement si reseau disponible.

### Push Strategy

- Rappels planifies en local, pas de notifications nocturnes.

### Implementation Considerations

- UX centree sur la discretion.
- Parametrage simple des plages horaires et permissions.

## Project Scoping & Phased Development

### MVP Strategy & Philosophy

**MVP Approach:** MVP "experience" (valider que le timing, le ton et la friction minimale creent l'habitude)

**Resource Requirements:** 1 dev Flutter + 1 backend + 1 designer

### MVP Feature Set (Phase 1)

**Core User Journeys Supported:**
- Utilisateur principal (happy path)
- Edge case permissions refusees
- Self-service sans support

**Must-Have Capabilities:**
- Onboarding avec categorisation des proches
- Permissions (localisation arriere-plan, contacts, calendrier)
- Rappels contextuels discrets (fenetres horaires)
- Actions 1-tap (Ecrire/Appeler)
- Mode degrade si permissions refusees
- Historique "dernier contact"
- Cadence par categories

### Post-MVP Features

**Phase 2 (Post-MVP):**
- Recommandations de messages personnalisees
- Contexte enrichi (calendrier, habitudes)
- Tableau de bord relationnel minimal

**Phase 3 (Expansion):**
- Rituels relationnels (anniversaires, moments cles)
- Intelligence de timing avancee

### Risk Mitigation Strategy

**Technical Risks:** fiabilite de la localisation en arriere-plan + app fluide sans bugs

**Market Risks:** les gens ignorent les rappels

**Resource Risks:** manque de temps pour iterer

## Functional Requirements

### Onboarding & Setup

- FR1: L'utilisateur peut creer son profil minimal avec nom/alias et fuseau horaire.
- FR2: L'utilisateur peut classer ses proches par categories (proches/eloignes/partenaire/amis).
- FR3: L'utilisateur peut definir ses lieux cles (maison, travail, entrainement).
- FR4: Le systeme peut guider la demande de permissions (localisation, contacts, calendrier, appels/SMS).

### Contacts & Relations

- FR5: L'utilisateur peut ajouter/retirer/modifier un proche dans une categorie.
- FR6: L'utilisateur peut definir la cadence de contact par categorie.
- FR7: L'utilisateur peut modifier la priorite d'un proche (ex. passer d'eloigne a proche).

### Contexte & Timing

- FR8: Le systeme peut declencher un rappel uniquement si le lieu correspond a un lieu cle et si l'heure est dans une plage autorisee.
- FR9: Le systeme peut eviter les rappels pendant les periodes de repos (nuit).
- FR10: Le systeme peut appliquer un "cooldown" apres un rappel ignore.

### Rappels & Notifications

- FR11: Le systeme peut declencher un rappel contextuel discret.
- FR12: L'utilisateur peut lancer "Ecrire" depuis une notification.
- FR13: L'utilisateur peut lancer "Appeler" depuis une notification.
- FR14: L'utilisateur peut indiquer "pas le bon moment" depuis la notification.

### Historique & Suivi

- FR15: L'utilisateur peut voir le dernier contact par proche.
- FR16: Le systeme peut mettre a jour l'historique apres un contact realise.

### Permissions & Mode Degrade

- FR17: Le systeme peut fonctionner en mode degrade si la localisation est refusee.
- FR18: L'utilisateur peut comprendre l'impact d'un refus de permission via un message clair.

### Offline

- FR19: Le systeme peut planifier et afficher des rappels en mode hors-ligne.
- FR20: Le systeme peut bloquer l'envoi de messages/appels en l'absence de reseau.

### Parametrage

- FR21: L'utilisateur peut ajuster les plages horaires de rappels.
- FR22: L'utilisateur peut activer/desactiver des categories de rappels.

### Valeur & Experience

- FR23: Le systeme peut afficher des messages issus d'un catalogue approuve (ton chaleureux, non culpabilisant).
- FR24: L'utilisateur peut effectuer les actions principales en 2-3 taps.

## Non-Functional Requirements

### Performance

- Ouverture de l'app < 2s (p95) mesuree par instrumentation en production.
- Affichage de l'ecran principal < 1s apres lancement (p95) mesuree par instrumentation en production.

### Reliability

- 95% des rappels delivres dans la fenetre prevue, mesure sur 30 jours via logs de notification.

### Security & Privacy

- Donnees locales chiffrees au repos (contacts, localisation, historique), verifie par audit securite.
- Aucun partage externe des donnees, verifie par revue des flux sortants.

### Scalability

- Support de 5 000 MAU avec pics x3 sans degradation visible, verifie par tests de charge trimestriels.

### Accessibility

- Contraste texte >= 4.5:1 et tailles de police systeme respectees, verifie par audit UX/WCAG.
