## ExtractMap

Un package pour extraire des valeurs de propriétés de sol, d'IQS potentiel et de climat à partir de fichiers tif

Auteurs: Isabelle Auger - Ministère des Ressources Naturelles et des Forêts du Québec

Courriel: isabelle.auger@mrnf.gouv.qc.ca

This R package is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This library is distributed with the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

See the license LGPL-3.0 at http://www.gnu.org/copyleft/lesser.html.

## Introduction
Le package permet d'extraire des valeurs de propriétés de sol, d'IQS potentiel et de climat, en fournissant des coordonnées, à partir de fichiers tif.

## Documentation et références
- Les cartes de propriétés de sol ont été téléchargées ici: https://www.donneesquebec.ca/recherche/dataset/siigsol-100m-carte-des-proprietes-du-sol
- Les IQS potentiels ont été téléchargés ici: https://www.foretouverte.gouv.qc.ca/
- Les cartes de variables climatiques ont été créées avec le logiciel BioSIM (Régnière et al. 2017)

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
install_github("https://github.com/Modelisation-DRF/ExtractMap", ref="main", auth_token = "demander_un_token")
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
Pour obtenir la liste des data.frame disponibles
```{r eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
data(package='TarifQC')
```
Pour une description du data.frame
```{r eval=FALSE, echo=FALSE, message=FALSE, warning=FALSE}
?fic_arbres_test
```

## Historique des versions

| Date |  Version  | Issues |      Détails     |
|:-----|:---------:|:-------|:-----------------|
| 2024-03-26 | 1.1.3 |  | déplacer les packages de depends à imports dans DESCRIPTION, utiliser la fct mvrnorm de rockchalk au lieu de MASS |
| 2024-02-22 | 1.1.2 |  | ajout de l'option na.rm=T dans le calcul de la st et densité de chaque placette |
| 2024-02-20 | 1.1.1 |  | correction de bugs mineurs détectés en utilisant un fichier de samare avec peu d'essences |
| 2024-02-08 | 1.1.0 | issue #1  | amélioration de la vitesse d'exécution en mode stochastique |
| 2023-11-30 | 1.0.0 | | première version stable |
