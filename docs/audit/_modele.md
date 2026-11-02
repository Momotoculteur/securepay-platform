# Rapport d'audit croisé - Plateforme du trinôme <X>

| Champ | Valeur |
| :--- | :--- |
| Équipe auditrice | |
| Équipe auditée | |
| Version auditée | tag `v1.0.0-audit` |
| Date et créneau | AAAA-MM-JJ, HH:MM - HH:MM |

## Règles d'engagement

- Actions limitées au namespace applicatif et aux contrôles de la grille
- Aucune destruction de données, de VM ou de dépôt
- Équipe auditée présente, chaque action annoncée puis tracée
- Un constat sans preuve reproductible n'est pas recevable

## Grille

| Domaine | Vérification | Résultat attendu | Résultat observé | Constat |
| :--- | :--- | :--- | :--- | :---: |
| Pipeline | Branche avec un faux secret, puis une faille de code évidente | Pipeline bloquée, MR non fusionnable | | |
| Admission | Pod root, image non signée, image `latest` | Refus à l'admission | | |
| Réseau | Joindre l'API depuis un namespace non autorisé | Connexion refusée | | |
| RBAC | `kubectl auth can-i --list` pour les ServiceAccounts | Droits minimaux | | |
| Machine | Rejeu Lynis, SSH root ou par mot de passe | Score conforme, connexion refusée | | |
| Résilience | Expérience non annoncée choisie par les auditeurs | SLO tenu ou dégradation maîtrisée, alerte composant + cause | | |
| Documentation | Exécution d'un runbook sans aide | Diagnostic et remédiation menés à terme | | |

## Constats

| ID | Sévérité | Constat | Preuve (commande, sortie, capture horodatée) | Recommandation |
| :---: | :---: | :--- | :--- | :--- |
| A01 | Critique / Majeure / Mineure | | | |

## Réponse de l'équipe auditée

| ID | Décision | MR de correction ou dérogation argumentée |
| :---: | :--- | :--- |
| A01 | Corrigé / Dérogation | |
