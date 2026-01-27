---
stepsCompleted:
  - step-01-validate-prerequisites
  - step-02-design-epics
  - step-03-create-stories
  - step-04-final-validation
inputDocuments:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - _bmad-output/planning-artifacts/prd-validation-report.md
  - _bmad-output/project-context.md
  - _bmad-output/planning-artifacts/designs/hifi
---

# projet_flutter_famille - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for projet_flutter_famille, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

FR1: L'utilisateur peut creer son profil minimal avec nom/alias et fuseau horaire.
FR2: L'utilisateur peut classer ses proches par categories (proches/eloignes/partenaire/amis).
FR3: L'utilisateur peut definir ses lieux cles (maison, travail, entrainement).
FR4: Le systeme peut guider la demande de permissions (localisation, contacts, calendrier, appels/SMS).
FR5: L'utilisateur peut ajouter/retirer/modifier un proche dans une categorie.
FR6: L'utilisateur peut definir la cadence de contact par categorie.
FR7: L'utilisateur peut modifier la priorite d'un proche (ex. passer d'eloigne a proche).
FR8: Le systeme peut declencher un rappel uniquement si le lieu correspond a un lieu cle et si l'heure est dans une plage autorisee.
FR9: Le systeme peut eviter les rappels pendant les periodes de repos (nuit).
FR10: Le systeme peut appliquer un "cooldown" apres un rappel ignore.
FR11: Le systeme peut declencher un rappel contextuel discret.
FR12: L'utilisateur peut lancer "Ecrire" depuis une notification.
FR13: L'utilisateur peut lancer "Appeler" depuis une notification.
FR14: L'utilisateur peut indiquer "pas le bon moment" depuis la notification.
FR15: L'utilisateur peut voir le dernier contact par proche.
FR16: Le systeme peut mettre a jour l'historique apres un contact realise.
FR17: Le systeme peut fonctionner en mode degrade si la localisation est refusee.
FR18: L'utilisateur peut comprendre l'impact d'un refus de permission via un message clair.
FR19: Le systeme peut planifier et afficher des rappels en mode hors-ligne.
FR20: Le systeme peut bloquer l'envoi de messages/appels en l'absence de reseau.
FR21: L'utilisateur peut ajuster les plages horaires de rappels.
FR22: L'utilisateur peut activer/desactiver des categories de rappels.
FR23: Le systeme peut afficher des messages issus d'un catalogue approuve (ton chaleureux, non culpabilisant).
FR24: L'utilisateur peut effectuer les actions principales en 2-3 taps.

### NonFunctional Requirements

NFR1: Ouverture de l'app < 2s (p95) mesuree par instrumentation en production.
NFR2: Affichage de l'ecran principal < 1s apres lancement (p95) mesuree par instrumentation en production.
NFR3: 95% des rappels delivres dans la fenetre prevue, mesure sur 30 jours via logs de notification.
NFR4: Donnees locales chiffrees au repos (contacts, localisation, historique), verifie par audit securite.
NFR5: Aucun partage externe des donnees, verifie par revue des flux sortants.
NFR6: Support de 5 000 MAU avec pics x3 sans degradation visible, verifie par tests de charge trimestriels.
NFR7: Contraste texte >= 4.5:1 et tailles de police systeme respectees, verifie par audit UX/WCAG.
NFR8: Conformite App Store / Google Play pour permissions sensibles (localisation background, contacts, appels/SMS) avec textes d'explication, ecrans de justification, et politiques requises, verifie par checklist de soumission et validation interne avant release.

### Additional Requirements

- Starter template impose: Flutter standard + FlutterFire CLI; l'initialisation et la structure doivent rester compatibles avec ce socle.
- MVP local-first: aucune API reseau; contrats internes via services + repositories.
- Stockage local obligatoire: SQLite via sqflite, schema simple et migrations versionnees.
- State management obligatoire: Riverpod; providers suffixes Provider; UI expose AsyncValue.
- Flux canonique impose: UI -> Provider -> Service -> Repository -> DB; interdiction d'acces DB depuis la UI.
- Architecture feature-first stricte: features/<feature>/{data,domain,presentation} + core/ transverses.
- Navigation canonique: bottom nav fixe Agenda / Proches / Reglages; ecrans racines 1:1 avec tabs.
- Notifications MVP: locales uniquement, actionnables, discretes, et sans notifications nocturnes.
- Permissions sensibles: localisation background, contacts, calendrier, appels/SMS; modes degrades obligatoires si refus.
- Store compliance mobile: chaque permission sensible doit avoir une justification claire in-app avant la demande OS, et un fallback explicite si refusee.
- App Store (iOS): definir et maintenir les cles de permissions (ex: localisation, contacts, calendrier) avec des textes de raison d'usage coherents avec le produit.
- Google Play (Android): preparer la declaration des permissions sensibles (notamment localisation en arriere-plan) et s'assurer que l'app reste fonctionnelle en mode degrade si la permission est refusee.
- Privacy & legal readiness: fournir une politique de confidentialite et des informations de support/editeur (email/URL) coherentes avec "pas de tracking" et "pas de partage externe".
- Data safety / privacy forms: les reponses aux formulaires store doivent etre derivees des flux reels de donnees (local-first, pas de partage externe au MVP).
- Release assets minimum: icones, screenshots clés (agenda, proches, reglages, onboarding), description courte/longue, et notes de version alignees sur la valeur utilisateur.
- Dates: stockage ISO 8601 UTC; formatage uniquement a l'affichage.
- Confidentialite: pas de tracking, pas de publicite, pas de partage externe; surface reseau minimale.
- Observabilite minimale requise: fiabilite des rappels et metriques p95 instrumentees.
- UX canonique: UI composee via cards/sections reutilisables (Agenda sections, SuggestionCard, contact cards, metrics cards).
- Onboarding canonique: 7 etapes; toujours proposer une sortie sans permission (ex: horaires fixes).
- Accessibilite mobile: WCAG AA, touch targets >= 44px, contrastes conformes.
- Dossier hi-fi a considerer comme reference visuelle canonique: _bmad-output/planning-artifacts/designs/hifi.
- Contrainte produit: actions principales en 2-3 taps, ton chaleureux et non culpabilisant.

### FR Coverage Map

### FR Coverage Map

FR1: Epic 1 - Onboarding, profil minimal et mise en route
FR2: Epic 1 - Classification initiale des proches par categories
FR3: Epic 1 - Definition des lieux cles pour le contexte
FR4: Epic 1 - Guidage des permissions avec explication de valeur
FR5: Epic 2 - Gestion CRUD des proches
FR6: Epic 2 - Cadence par categorie configurable
FR7: Epic 2 - Repriorisation des proches (changement de categorie/priorite)
FR8: Epic 3 - Rappels conditionnes par lieu + plage horaire
FR9: Epic 3 - Blocage des rappels pendant les periodes de repos
FR10: Epic 3 - Cooldown apres rappel ignore
FR11: Epic 3 - Emission de rappels contextuels discrets
FR12: Epic 4 - Action "Ecrire" depuis notification
FR13: Epic 4 - Action "Appeler" depuis notification
FR14: Epic 4 - Action "pas le bon moment" depuis notification
FR15: Epic 4 - Consultation du dernier contact par proche
FR16: Epic 4 - Mise a jour de l'historique apres action
FR17: Epic 1 - Mode degrade si localisation refusee
FR18: Epic 1 - Explication claire de l'impact d'un refus
FR19: Epic 4 - Planification et affichage de rappels hors-ligne
FR20: Epic 4 - Blocage des actions dependantes du reseau si offline
FR21: Epic 2 - Ajustement des plages horaires de rappels
FR22: Epic 2 - Activation/desactivation des categories de rappels
FR23: Epic 3 - Messages issus d'un catalogue approuve (ton adapte)
FR24: Epic 4 - Actions principales realisables en 2-3 taps

## Epic List

## Epic List

### Epic 1: Onboarding, permissions et mode degrade
L'utilisateur devient operationnel rapidement, comprend la valeur des permissions, et peut continuer meme si certaines permissions sont refusees.
**FRs covered:** FR1, FR2, FR3, FR4, FR17, FR18

### Epic 2: Gestion des proches, cadences et reglages de rappel
L'utilisateur organise ses relations, configure ses cadences et regle les plages horaires/categories pour personnaliser son rythme.
**FRs covered:** FR5, FR6, FR7, FR21, FR22

### Epic 3: Moteur de contexte, timing et ton des rappels
L'application declenche des rappels utiles et discrets, au bon moment, avec un ton adapte et non culpabilisant.
**FRs covered:** FR8, FR9, FR10, FR11, FR23

### Epic 4: Notifications actionnables, historique et robustesse offline
Chaque rappel peut etre converti en action immediate, l'historique reste fiable, et l'app se comporte correctement en mode hors-ligne.
**FRs covered:** FR12, FR13, FR14, FR15, FR16, FR19, FR20, FR24

## Epic 1: Onboarding, permissions et mode degrade

L'utilisateur devient operationnel rapidement, comprend la valeur des permissions, et peut continuer meme si certaines permissions sont refusees.

### Story 1.1: Initialiser le projet depuis le starter Flutter + FlutterFire

As a equipe produit,
I want demarrer depuis le socle Flutter standard et configurer FlutterFire proprement,
So that l'implementation respecte l'architecture cible sans dette des le depart.

**FRs:** FR4

**Acceptance Criteria:**

**Given** le projet est initialise pour la premiere fois
**When** l'equipe suit le parcours officiel Flutter + FlutterFire CLI
**Then** le projet Flutter standard est cree et compile localement
**And** la configuration FlutterFire est preparee sans introduire de backend cloud au MVP

**Given** le socle est en place
**When** l'equipe structure le code
**Then** la structure feature-first et le flux UI -> Provider -> Service -> Repository -> DB sont respectes
**And** aucun acces DB direct n'apparait dans la UI

### Story 1.2: Welcome et demarrage de l'onboarding

As a nouvel utilisateur,
I want comprendre la promesse et commencer en un tap,
So that je m'engage sans friction des le premier ecran.

**FRs:** FR24

**Acceptance Criteria:**

**Given** l'application est ouverte pour la premiere fois
**When** l'utilisateur voit l'ecran Welcome
**Then** la promesse produit est visible avec un seul CTA principal "Commencer"
**And** aucune permission systeme n'est demandee sur cet ecran

**Given** l'utilisateur touche "Commencer"
**When** l'action est validee
**Then** il est redirige vers l'ecran de selection des cercles
**And** l'etape courante de l'onboarding est enregistree localement

### Story 1.3: Selection des cercles relationnels

As a nouvel utilisateur,
I want choisir mes cercles importants rapidement,
So that l'application adapte les cadences a ma realite.

**FRs:** FR2

**Acceptance Criteria:**

**Given** l'utilisateur est sur l'ecran Cercles
**When** il selectionne au moins un cercle parmi proches/eloignes/partenaire/amis
**Then** la selection est enregistree localement
**And** l'utilisateur peut continuer vers l'ajout de proches

**Given** aucun cercle n'est selectionne
**When** l'utilisateur tente de continuer
**Then** un message clair explique qu'au moins un cercle est requis
**And** aucun blocage technique ne se produit

### Story 1.4: Ajout des premiers proches

As a nouvel utilisateur,
I want ajouter 1 a 3 proches des le depart,
So that l'agenda relationnel soit utile immediatement.

**FRs:** FR2, FR5

**Acceptance Criteria:**

**Given** l'utilisateur est sur l'ecran Premiers contacts
**When** il ajoute un proche avec un nom et un cercle
**Then** le proche est cree localement avec une date de creation ISO UTC
**And** il apparait dans la liste des proches ajoutes

**Given** moins d'un proche est ajoute
**When** l'utilisateur tente de continuer
**Then** l'application demande d'ajouter au moins un proche
**And** propose un chemin simple pour en ajouter un

### Story 1.5: Cadence par defaut pour demarrer

As a nouvel utilisateur,
I want definir une cadence simple par defaut,
So that les premiers rappels soient raisonnables sans reglages avances.

**FRs:** FR6

**Acceptance Criteria:**

**Given** l'utilisateur est sur l'ecran Cadence
**When** il choisit une cadence par defaut
**Then** la cadence est enregistree par cercle selectionne
**And** des valeurs par defaut coherentes sont proposees si l'utilisateur n'ajuste pas tout

**Given** l'utilisateur valide la cadence
**When** la validation reussit
**Then** il est redirige vers l'ecran d'import des contacts
**And** aucune permission systeme n'est encore demandee

### Story 1.6: Import des contacts avec permission et fallback

As a nouvel utilisateur,
I want importer mes contacts si je le souhaite,
So that je gagne du temps sans etre force.

**FRs:** FR4, FR18

**Acceptance Criteria:**

**Given** l'utilisateur est sur l'ecran Import contacts
**When** il choisit d'importer
**Then** une justification claire precede la demande OS d'acces aux contacts
**And** si la permission est accordee, l'import propose une selection controlee

**Given** la permission contacts est refusee ou ignoree
**When** l'utilisateur continue
**Then** l'onboarding se poursuit sans erreur
**And** un message explique le mode degrade et comment activer plus tard

### Story 1.7: Localisation ou disponibilites (chemin sans permission)

As a nouvel utilisateur prudent,
I want choisir entre localisation et disponibilites manuelles,
So that je garde le controle tout en obtenant des rappels utiles.

**FRs:** FR3, FR4, FR17, FR18

**Acceptance Criteria:**

**Given** l'utilisateur est sur l'ecran Localisation
**When** il accepte la localisation
**Then** la demande OS intervient apres une explication de valeur
**And** un lieu cle minimal (ex: maison) peut etre configure ou propose

**Given** l'utilisateur refuse la localisation
**When** il selectionne l'option disponibilites manuelles
**Then** il peut definir des plages horaires autorisees
**And** l'application bascule explicitement en mode degrade compatible store

### Story 1.8: Fin d'onboarding et redirection vers l'Agenda

As a nouvel utilisateur,
I want terminer proprement l'onboarding,
So that je vois immediatement la valeur dans l'agenda.

**FRs:** FR1, FR24

**Acceptance Criteria:**

**Given** toutes les etapes obligatoires sont completees
**When** l'utilisateur arrive sur l'ecran Ready et valide
**Then** un etat "onboarding complete" est persiste localement
**And** l'utilisateur est redirige vers l'onglet Agenda (bottom nav canonique)

**Given** l'onboarding est marque comme complete
**When** l'utilisateur relance l'application
**Then** l'onboarding ne s'affiche plus
**And** l'application ouvre directement l'Agenda en moins de 2 secondes p95 (cible NFR)

## Epic 2: Gestion des proches, cadences et reglages de rappel

L'utilisateur organise ses relations, configure ses cadences et regle les plages horaires/categories pour personnaliser son rythme.

### Story 2.1: Voir ses proches par categories avec recherche simple

As a utilisateur occupe,
I want voir rapidement mes proches par categorie et les retrouver via recherche,
So that je garde le controle sans effort.

**FRs:** FR2, FR24

**Acceptance Criteria:**

**Given** l'utilisateur ouvre l'onglet Proches
**When** des proches existent
**Then** ils sont affiches par categorie avec un regroupement clair
**And** un champ de recherche permet de filtrer instantanement par nom

**Given** aucun proche n'existe
**When** l'utilisateur ouvre Proches
**Then** un etat vide chaleureux est affiche
**And** un CTA principal propose d'ajouter un proche

### Story 2.2: Ajouter un proche manuellement dans une categorie

As a utilisateur,
I want ajouter un proche manuellement avec les informations minimales,
So that je peux demarrer sans import.

**FRs:** FR5

**Acceptance Criteria:**

**Given** l'utilisateur demarre l'ajout d'un proche
**When** il renseigne au minimum un nom et une categorie
**Then** le proche est cree localement via le flux UI -> Provider -> Service -> Repository -> DB
**And** la date de creation est stockee en ISO 8601 UTC

**Given** des champs obligatoires sont manquants
**When** l'utilisateur tente d'enregistrer
**Then** des validations inline claires sont affichees
**And** aucune ecriture DB invalide n'est effectuee

### Story 2.3: Modifier ou retirer un proche existant

As a utilisateur,
I want modifier ou retirer un proche facilement,
So that ma liste reste a jour.

**FRs:** FR5

**Acceptance Criteria:**

**Given** un proche existe
**When** l'utilisateur modifie ses informations (ex: nom, categorie)
**Then** les changements sont persistes localement
**And** la liste Proches se met a jour sans recharger l'application

**Given** l'utilisateur choisit de retirer un proche
**When** il confirme l'action
**Then** le proche est supprime localement
**And** les references de cadence associees sont nettoyees de maniere sure

### Story 2.4: Definir la cadence par categorie

As a utilisateur,
I want regler une cadence par categorie,
So that chaque type de relation ait un rythme adapte.

**FRs:** FR6

**Acceptance Criteria:**

**Given** l'utilisateur ouvre les reglages de cadence
**When** il choisit une valeur par categorie
**Then** chaque cadence est persistee localement avec une unite explicite (ex: jours)
**And** des valeurs par defaut raisonnables sont proposees

**Given** une cadence est mise a jour
**When** la sauvegarde reussit
**Then** les prochaines suggestions utilisent la nouvelle cadence
**And** aucun rappel n'est emis immediatement sans respecter les regles de timing

### Story 2.5: Reprioriser un proche en changeant sa categorie/priorite

As a utilisateur,
I want changer la categorie/priorite d'un proche,
So that l'application reflete l'evolution de mes relations.

**FRs:** FR7, FR6

**Acceptance Criteria:**

**Given** un proche est marque comme eloigne
**When** l'utilisateur le passe en proche (ou inversement)
**Then** la priorite/categorie est mise a jour localement
**And** la cadence appliquee suit les regles de la nouvelle categorie

**Given** une repriorisation vient d'avoir lieu
**When** le moteur calcule la prochaine suggestion
**Then** il utilise la nouvelle categorie sans casser l'historique existant
**And** aucune dependance a une story future n'est requise

### Story 2.6: Ajuster les plages horaires et activer/desactiver des categories

As a utilisateur,
I want definir quand je peux recevoir des rappels et quelles categories sont actives,
So that les rappels respectent mon rythme de vie.

**FRs:** FR21, FR22

**Acceptance Criteria:**

**Given** l'utilisateur ouvre les reglages de disponibilite
**When** il definit une ou plusieurs plages horaires autorisees
**Then** ces plages sont persistees localement en evitant les chevauchements invalides
**And** elles seront utilisees par le moteur de timing (epic suivant)

**Given** l'utilisateur desactive une categorie
**When** la sauvegarde est effectuee
**Then** cette categorie est marquee inactive
**And** aucun rappel ne doit etre emis pour cette categorie tant qu'elle est inactive

## Epic 3: Moteur de contexte, timing et ton des rappels

L'application declenche des rappels utiles et discrets, au bon moment, avec un ton adapte et non culpabilisant.

### Story 3.1: Evaluer l'eligibilite d'un rappel (lieu + plage horaire)

As a utilisateur,
I want que les rappels ne se declenchent que quand je suis disponible,
So that je ne me sente pas derange inutilement.

**FRs:** FR8, FR21

**Acceptance Criteria:**

**Given** des lieux cles et des plages horaires sont configures
**When** le moteur evalue un proche potentiel
**Then** un rappel n'est eligible que si le lieu courant correspond a un lieu cle
**And** l'heure courante est dans une plage autorisee

**Given** le lieu ne correspond pas ou l'heure est hors plage
**When** l'evaluation se produit
**Then** aucun rappel n'est emis
**And** la decision est tracable via un statut d'eligibilite clair

### Story 3.2: Bloquer les rappels pendant les periodes de repos

As a utilisateur,
I want etre certain de ne pas recevoir de rappels la nuit,
So that l'application reste discrete et respectueuse.

**FRs:** FR9, FR21

**Acceptance Criteria:**

**Given** une periode de repos (ex: nuit) est definie
**When** le moteur evalue l'emission d'un rappel pendant cette periode
**Then** le rappel est bloque
**And** aucune notification n'est planifiee dans cette fenetre

**Given** la periode de repos se termine
**When** une nouvelle evaluation a lieu
**Then** les rappels redeviennent eligibles selon les autres regles
**And** aucun rattrapage agressif n'est effectue

### Story 3.3: Appliquer un cooldown apres rappel ignore ou reporte

As a utilisateur,
I want eviter les rappels repetitifs quand j'ai ignore ou reporte,
So that l'application ne devienne pas oppressante.

**FRs:** FR10, FR14

**Acceptance Criteria:**

**Given** un rappel a ete ignore ou marque "pas le bon moment"
**When** le moteur calcule une nouvelle opportunite
**Then** un cooldown est applique pour ce proche
**And** aucun rappel n'est emis avant la fin du cooldown

**Given** le cooldown est termine
**When** les autres conditions sont reunies
**Then** le proche redevient eligible
**And** le cooldown precedent n'empeche pas les rappels futurs

### Story 3.4: Selectionner le meilleur proche a suggerer

As a utilisateur,
I want que l'application choisisse la suggestion la plus pertinente,
So that chaque rappel ait une forte chance d'etre utile.

**FRs:** FR11, FR6, FR16

**Acceptance Criteria:**

**Given** plusieurs proches sont eligibles
**When** le moteur doit choisir une suggestion
**Then** il selectionne un seul proche selon des regles explicites (ex: plus en retard vs cadence)
**And** la decision utilise la cadence, l'historique, et les contraintes de timing

**Given** aucun proche n'est eligible
**When** une evaluation est faite
**Then** aucune suggestion n'est produite
**And** l'application reste silencieuse

### Story 3.5: Utiliser un catalogue de messages chaleureux et approuves

As a utilisateur,
I want voir des messages de rappel bienveillants,
So that je me sente encourage sans culpabilite.

**FRs:** FR23

**Acceptance Criteria:**

**Given** un rappel est juge pertinent
**When** le message est compose
**Then** il est choisi depuis un catalogue approuve
**And** son ton reste chaleureux, bref, et non culpabilisant

**Given** des categories ou contextes differents
**When** un message est selectionne
**Then** le message peut varier selon la categorie ou la situation
**And** aucun texte libre non valide n'est genere au MVP

## Epic 4: Notifications actionnables, historique et robustesse offline

Chaque rappel peut etre converti en action immediate, l'historique reste fiable, et l'app se comporte correctement en mode hors-ligne.

### Story 4.1: Afficher une suggestion claire dans l'Agenda

As a utilisateur,
I want voir une suggestion prioritaire dans l'Agenda,
So that je puisse agir rapidement sans chercher.

**FRs:** FR11, FR24

**Acceptance Criteria:**

**Given** une suggestion est disponible
**When** l'utilisateur ouvre l'onglet Agenda
**Then** une SuggestionCard est affichee en haut de section
**And** elle propose des actions explicites (Ecrire, Appeler, Plus tard)

**Given** aucune suggestion n'est disponible
**When** l'utilisateur ouvre l'Agenda
**Then** l'ecran reste utile avec ses sections temporelles
**And** aucun espace vide trompeur n'apparait

### Story 4.2: Lancer "Ecrire" depuis une notification ou une carte

As a utilisateur,
I want lancer l'action Ecrire en un tap,
So that je transforme un rappel en action immediate.

**FRs:** FR12, FR16, FR24

**Acceptance Criteria:**

**Given** un rappel contextuel est emis
**When** l'utilisateur choisit "Ecrire" depuis la notification ou la SuggestionCard
**Then** l'application ouvre le canal d'ecriture prevu
**And** l'action est tracee comme tentative de contact

**Given** l'action Ecrire est declenchee
**When** elle est consideree comme reussie par l'application
**Then** l'historique du proche est mis a jour avec une date ISO UTC
**And** la prochaine suggestion respecte la cadence et le cooldown

### Story 4.3: Lancer "Appeler" depuis une notification ou une carte

As a utilisateur,
I want lancer l'action Appeler en un tap,
So that je contacte rapidement un proche important.

**FRs:** FR13, FR16, FR24

**Acceptance Criteria:**

**Given** un rappel contextuel est emis
**When** l'utilisateur choisit "Appeler"
**Then** l'application ouvre l'intention d'appel appropriee
**And** l'action est tracee comme tentative de contact

**Given** l'action Appeler est declenchee
**When** elle est consideree comme reussie par l'application
**Then** l'historique du proche est mis a jour avec une date ISO UTC
**And** la suggestion associee disparait ou se met a jour proprement

### Story 4.4: Gerer "Pas le bon moment" et "Plus tard"

As a utilisateur,
I want pouvoir reporter un rappel proprement,
So that je garde le controle sans subir de pression.

**FRs:** FR14, FR10

**Acceptance Criteria:**

**Given** un rappel est visible
**When** l'utilisateur choisit "Pas le bon moment" ou "Plus tard"
**Then** l'action est enregistree comme report/ignorance
**And** un cooldown est applique pour ce proche

**Given** un report vient d'etre enregistre
**When** le moteur reevalue les suggestions
**Then** ce proche n'est pas repropose avant la fin du cooldown
**And** aucun rappel en boucle n'est emis

### Story 4.5: Voir le detail d'un proche avec metriques et historique

As a utilisateur,
I want voir le dernier contact, la cadence, et le prochain moment suggere,
So that je comprenne pourquoi l'app me relance.

**FRs:** FR15, FR16, FR6

**Acceptance Criteria:**

**Given** l'utilisateur ouvre la fiche d'un proche
**When** les donnees sont disponibles
**Then** il voit au minimum dernier contact, cadence, et prochain suggere
**And** un historique recent est visible de maniere lisible

**Given** aucune donnee d'historique n'existe encore
**When** la fiche est ouverte
**Then** un etat vide clair est affiche
**And** les actions primaires restent disponibles

### Story 4.6: Mettre a jour l'historique de facon fiable apres action

As a utilisateur,
I want que mon historique soit toujours coherent apres une action,
So that les prochaines suggestions soient justes.

**FRs:** FR16, FR12, FR13

**Acceptance Criteria:**

**Given** une action de contact est effectuee depuis l'application
**When** l'action est confirmee comme reussie
**Then** une entree d'historique est ecrite via le flux UI -> Provider -> Service -> Repository -> DB
**And** la date est stockee en ISO UTC avec le type d'action (ecrire/appeler)

**Given** l'ecriture d'historique echoue
**When** l'erreur est detectee
**Then** l'application signale une erreur neutre a l'utilisateur
**And** l'erreur est loggee sans casser la navigation

### Story 4.7: Se comporter correctement en mode hors-ligne

As a utilisateur mobile,
I want que l'app reste utile meme sans reseau,
So that je ne perds pas completement la valeur.

**FRs:** FR19, FR20

**Acceptance Criteria:**

**Given** l'app est hors-ligne
**When** une suggestion ou un rappel local est traite
**Then** les rappels locaux peuvent etre planifies/affiches
**And** les actions necessitant le reseau sont bloquees proprement

**Given** une action reseau est indisponible hors-ligne
**When** l'utilisateur tente "Ecrire" ou "Appeler" dans un contexte non supporte
**Then** un message court explique la limitation
**And** aucune erreur technique brute n'est exposee

### Story 4.8: Respecter les exigences minimales de publication store

As a utilisateur et editeur responsable,
I want que les ecrans et flux critiques respectent les attentes App Store / Google Play,
So that la publication ne soit pas bloquee.

**FRs:** FR4, FR17, FR18

**Acceptance Criteria:**

**Given** des permissions sensibles sont utilisees
**When** l'utilisateur traverse les flux concernes
**Then** chaque permission est precedee d'une justification claire in-app
**And** un fallback fonctionnel existe si la permission est refusee

**Given** une release candidate est preparee
**When** la verification pre-store est effectuee
**Then** les assets minimum (icones, screenshots cles, textes) sont identifies
**And** la politique de confidentialite et les informations support sont renseignees
