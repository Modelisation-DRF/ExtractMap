# Tous les fichiers internes excel/csv/sas7bdat doivent être convertis en en seul fichier rda nommé sysdata.rda sous /R
# Tous les fichiers d'exemples doivent être convertis individuellement en rda et mis sous /data
# le fichier avec le code pour créer le fichier sysdata.rda doit être sauvegardé sous R/data-raw

# param_tarif = read.sas7bdat("c:/Mes docs/ data/ beta_volume.sas7bdat")
# param_ht = read.sas7bdat("c:/Mes docs/ data/ beta_ht.sas7bdat")
# Puis utiliser la ligne de code suivant (toujours dans le projet du package)
# usethis::use_data(param_tarif, param_ht, internal=TRUE): ça fonctionne seulement si le projet est un package

# library(tidyverse)
# library(sf)
# library(raster)


########################################################################################
# Fichier des cartes d'IQS

repertoire="P:\\F1272\\CPF\\IQS_potentiel\\"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_iqs <- list()
for (i in 1:length(liste))
{
  cartes_iqs[[i]] <- stack(paste0(repertoire,liste[[i]]))
}
names(cartes_iqs) <- gsub(".tif","",tolower(liste))
# [1] "iqs_pot_bop" "iqs_pot_epb" "iqs_pot_epn" "iqs_pot_epr" "iqs_pot_pex" "iqs_pot_pib"
# [7] "iqs_pot_pig" "iqs_pot_sab" "iqs_pot_tho"

########################################################################################

########################################################################################
# Fichier des cartes de sol

repertoire="P:\\F1272\\CPF\\SIGSOL\\Cartes_20220831\\"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_sol <- list()
for (i in 1:length(liste))
{
  cartes_sol[[i]] <- stack(paste0(repertoire,liste[[i]]))
}
names(cartes_sol) <- gsub(".tif","",tolower(liste)) # "cec"  "clay" "oc"   "ph"   "sand" "silt"

#names(cartes_sol[[1]]) # "X000.005cm" "X005.015cm" "X015.030cm" "X030.060cm" "X060.100cm" "X100.200cm"
#names(cartes_sol)[[1]] # cec
#names(cartes_sol[[1]])[[1]] # "X000.005cm"
#paste(names(cartes_sol)[[1]],names(cartes_sol[[1]])[[1]], sep='.')

########################################################################################

########################################################################################
# Fichier des cartes de climat normales 30 ans

repertoire="P:\\F1272\\CPF\\Biosim\\Cartes_climat_normales\\"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_climat <- list()
for (i in 1:length(liste))
{
  cartes_climat[[i]] <- stack(paste0(repertoire,liste[[i]]))
}
names(cartes_climat) <- gsub(".tif","", tolower(liste)) # 22 variables
# [1] "aridity"                     "consecutivedayswithoutfrost"
# [3] "dayswithoutfrost"            "degreeday"
# [5] "firstfrostday"               "growingseasonlength"
# [7] "growingseasonprecipitation"  "growingseasonradiation"
# [9] "growingseasontmean"          "julytmean"
# [11] "lastfrostday"                "pet"
# [13] "snowfallproportion"          "tmax"
# [15] "tmean"                       "tmin"
# [17] "totalprecipitation"          "totalradiation"
# [19] "totalsnowfall"               "totalvpd"
# [21] "utilprecipitation"           "utilvpd"


########################################################################################



########################################################################################
# Fichier des cartes de climat annuels

repertoire="P:\\F1272\\CPF\\Biosim\\Cartes_climat_annuel\\"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_climat_an <- list()
for (i in 1:length(liste))
{
  cartes_climat_an[[i]] <- stack(paste0(repertoire,liste[[i]]))
}
# nommer les éléments
names(cartes_climat_an) <- gsub(".tif","",liste) # enlever le .tif du nom
names(cartes_climat_an) <- tolower(gsub("RF","", names(cartes_climat_an))) # enlever le RF au début et mettre en minuscule
# "growingseasonprecipitation1980" "growingseasontmean1980" etc

########################################################################################


# tous les fichiers à mettre dans le rda
usethis::use_data(cartes_iqs, cartes_sol, cartes_climat, cartes_climat_an,
                  internal=TRUE, overwrite = TRUE)
