# Registre des risques - SecurePay Platform

> Jalon J1. Point de départ de toute la plateforme : chaque contrôle (Quality Gate, politique, durcissement, alerte) doit couvrir un risque de ce registre, et chaque risque doit avoir un contrôle et une preuve.

**Méthode :** STRIDE (*Spoofing*, *Tampering*, *Repudiation*, *Information disclosure*, *Denial of service*, *Elevation of privilege*).  
**Cotation :** Vraisemblance (1-4) × Impact (1-4) = Criticité (1-16).  
**Dernière revue :** AAAA-MM-JJ, par : ...

## Registre

| ID | STRIDE | Actif | Scénario de menace | V | I | Criticité | Contrôle prévu | Preuve attendue | Statut |
| :---: | :---: | :--- | :--- | :---: | :---: | :---: | :--- | :--- | :---: |
| R01 | I | Clé API Stripe | Un secret committé dans Git est récupéré par un bot qui scanne les dépôts | 4 | 4 | 16 | Détection de secrets bloquante en CI + rotation | Pipeline bloquée sur un faux secret (capture) | À faire |
| R02 | | | | | | | | | |
| R03 | | | | | | | | | |
| R04 | | | | | | | | | |
| R05 | | | | | | | | | |
| R06 | | | | | | | | | |
| R07 | | | | | | | | | |
| R08 | | | | | | | | | |

TODO [J1] : au moins 8 risques couvrant les six catégories STRIDE et les trois couches de la plateforme (chaîne de livraison, machine, cluster).

## Risques acceptés

| ID | Justification de l'acceptation | Validé par | Date de revue |
| :---: | :--- | :--- | :--- |
| | | | |
