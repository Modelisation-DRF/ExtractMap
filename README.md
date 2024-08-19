[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0) [![R-CMD-check](https://github.com/Modelisation-DRF/RNatura2014/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Modelisation-DRF/RNatura2014/actions/workflows/R-CMD-check.yaml)

## Le package ExtractMap

Un package pour extraire des valeurs de propriétés de sol, d'IQS potentiel, de station et de climat à partir de fichiers tif

Auteurs: Isabelle Auger - Ministère des Ressources Naturelles et des Forêts du Québec

Courriel: isabelle.auger@mrnf.gouv.qc.ca

## Introduction
Le package permet d'extraire des valeurs de propriétés de sol, d'IQS potentiel, de station et de climat, en fournissant des coordonnées, à partir de fichiers tif fournis dans le package.

## Documentation et références
- Les cartes de propriétés de sol ont été téléchargées ici: https://www.donneesquebec.ca/recherche/dataset/siigsol-100m-carte-des-proprietes-du-sol, et ont été aggrégées aux 1000x1000m
- Les IQS potentiels ont été téléchargés ici: https://www.foretouverte.gouv.qc.ca/. La taille d'un pixel est de 1000m x 1000m
- Les cartes de variables climatiques ont été créées avec le logiciel BioSIM (Régnière et al. 2017) et ont été aggrégés environ aux 1000x1000m
- Les cartes de station (pente et exposition) ont été créées par Jean Noël, à partir de la carte d'altitude de la DIF.

## Dépendences
Aucune dépendence à des packages externes à CRAN

## Comment obtenir le code source
Taper cette ligne dans une invite de commande pour cloner le dépôt dans un sous-dossier "extractmap":

```{r eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
git clone https://github.com/Modelisation-DRF/ExtractMap extractmap
```

## Comment installer le package ExtractMap dans R

```{r eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
require(remotes)
remotes::install_github("Modelisation-DRF/ExtractMap")
```
## Exemple

Ce package inclut un objet de type data.frame contenent des coordonnées. Cet objet peut être utilisé pour essayer le package.

```{r eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
library(ExtractMap)
iqs <- extract_map_plot(file=fic_test, liste_raster="cartes_iqs", variable=c("iqs_pot_bop","iqs_pot_epn"))
```
De l'aide supplémentaire peut être obtenu sur les fonctions
```{r eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
?extract_map_plot
?extract_climat_an
```

## Historique des versions

| Date |  Version  | Issues |      Détails     |
|:-----|:---------:|:-------|:-----------------|
| 2024-08-19 | 1.3.0 |  | ajout cartes de station avec pente et exposition |
| 2024-07-23 | 1.2.0 |  | ajout profondeur 5-15cm cartes SIIGSOL, ne supprime plus lignes avec obs manquantes, ajout vérif si variable déjà dans fichier  |
| 2024-05-14 | 1.1.3 |  | création de nouveaux tif moins lourds en arrondissant les valeurs |
| 2024-04-03 | 1.1.2 |  | création de nouveaux tif moins lourds en aggrégeant et en diminuant l'extent |
| 2024-03-26 | 1.1.1 |  | déplacer les package de depends à imports dans DESCRIPTION |
| 2024-03-13 | 1.1.0 | issue #1  | ne fonctionne pas avec quand les cartes sont sauvegardées en objet spatial, les tif doivent être dans le package |
| 2024-02-15 | 1.0.0 | | première version stable |
