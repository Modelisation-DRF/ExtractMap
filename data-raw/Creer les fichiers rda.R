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

#repertoire="P:\\F1272\\CPF\\IQS_potentiel\\"
# il faut que les données soient dans le package, en tout cas pour des raster, car le raster contient des infos sur le tif d'origine
repertoire="data-raw/IQS_potentiel/"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_iqs <- list()
for (i in 1:length(liste))
{
  # i=1
  #cartes_iqs[[i]] <- stack(paste0(repertoire,liste[[i]]))
  cartes_iqs[[i]] <- terra::rast(paste0(repertoire,liste[[i]]))
}
names(cartes_iqs) <- gsub(".tif","",tolower(liste))
# [1] "iqs_pot_bop" "iqs_pot_epb" "iqs_pot_epn" "iqs_pot_epr" "iqs_pot_pex" "iqs_pot_pib"
# [7] "iqs_pot_pig" "iqs_pot_sab" "iqs_pot_tho"
# plot(cartes_iqs[[1]])

# save(cartes_iqs, file="inst/extdata/cartes_iqs.RData")
usethis::use_data(cartes_iqs, overwrite = TRUE)


########################################################################################

########################################################################################
# Fichier des cartes de sol

#repertoire="P:\\F1272\\CPF\\SIGSOL\\Cartes_20220831\\"
# il faut que les données soient dans le package, en tout cas pour des raster, car le raster contient des infos sur le tif d'origine
repertoire="data-raw/SIGSOL/Cartes_20220831/"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_sol <- list()
for (i in 1:length(liste))
{
  #cartes_sol[[i]] <- stack(paste0(repertoire,liste[[i]]))
  cartes_sol[[i]] <- terra::rast(paste0(repertoire,liste[[i]]))
}
names(cartes_sol) <- gsub(".tif","",tolower(liste)) # "cec"  "clay" "oc"   "ph"   "sand" "silt"
# plot(cartes_sol[[1]][[1]])
#names(cartes_sol[[1]]) # "X000.005cm" "X005.015cm" "X015.030cm" "X030.060cm" "X060.100cm" "X100.200cm"
#names(cartes_sol)[[1]] # cec
#names(cartes_sol[[1]])[[1]] # "X000.005cm"
#paste(names(cartes_sol)[[1]],names(cartes_sol[[1]])[[1]], sep='.')

#save(cartes_sol, file="inst/extdata/cartes_sol.RData")
usethis::use_data(cartes_sol, overwrite = TRUE)
saveRDS(cartes_sol, file="data/cartes_sol.rds")
cartes_sol <- readRDS(file="data/cartes_sol.rds")



# test
fic <- paste0(repertoire,liste[[1]])
cec <- terra::rast(fic) # lit la premiere couche
writeRaster(cec[[1]],"data/cec1.tif")
writeRaster(cec[[2]],"data/cec2.tif")
writeRaster(cec[[3]],"data/cec3.tif")
writeRaster(cec[[4]],"data/cec4.tif")
writeRaster(cec[[5]],"data/cec5.tif")
writeRaster(cec[[6]],"data/cec6.tif")

cec <- stack(fic) # lit toutes les couches
cec <- raster::raster(fic) # lit la premiere couche
#writeRaster(cec,"data/cec.tif")
cec2 <- as(cec, "SpatialPixelsDataFrame") # 811 678 k et c'était 2.6 gb dans r, mais seulement une couche
#cec2a <- as(cec, "SpatialGridDataFrame") # 8.9 gb dans r!!
saveRDS(cec2, file="data/cec2.rds")
cec2 <- readRDS(file="data/cec2.rds")

cec3 <- as(cec2, "RasterLayer") # ça fait un large rasterlayer 1.5 gb dans r
plot(cec[[2]])
#plot(cec2$X000.005cm)
# save metadata
metadata_cec <- list(xmin = xmin(cec),xmax = xmax(cec),ymin = ymin(cec),ymax = ymax(cec),
                 nrows=nrow(cec), ncols=ncol(cec),
                 crs = crs(cec), resolution = res(cec),
                 nlayer = nlyr(cec))
#usethis::use_data(metadata_cec, overwrite=TRUE)

# Save raster values
raster_values_cec <- values(cec) # très gros, aussi gros que le tif
#raster_values_cec2 <- data.frame(raster_values_cec)
#usethis::use_data(raster_values_cec, overwrite=TRUE)

usethis::use_data(metadata_cec, raster_values_cec2,
                  internal=TRUE, overwrite = TRUE)


cec_reconstruit <- rast(vals=raster_values_cec,
                            nrows = metadata_cec$nrows,
                            nlyr = metadata_cec$nlayer,
                            ncols=metadata_cec$ncols,
                            xmin = metadata_cec$xmin,
                            ymin = metadata_cec$ymin,
                            xmax = metadata_cec$xmax,
                            ymax = metadata_cec$ymax,
                            crs = metadata_cec$crs)
plot(cec_reconstruit)
saveRDS(cartes_sol, file="data/cec_reconstruit.rds")
cec_reconstruit <- readRDS(file="data/cec_reconstruit.rds")

# sinon c'est de faire comme dans java, faire un fichier txt avec les valeurs du raster avec les coordonnées des 4 coins de chaque
# cellule et de faire une fct qui trouve dans quelle cellule tombe la coordonnéee

# sinon il faut mettre toues les tif dans le répertoire data, et utiliser le path actif pour aller les lire
# avec systeme.file
# le problème c'est que les fichier de sol sont tres gros, mettre seulement la 1ere couche?
# les 6 fichiers individuels sont ensemble aussi gros que le tif des 6 couches
# ça fait un package qui est long a loader
# et il sera peut etre trop gros pour mettre sur le serveur shinyapp

########################################################################################

########################################################################################
# Fichier des cartes de climat normales 30 ans

#repertoire="P:\\F1272\\CPF\\Biosim\\Cartes_climat_normales\\"
# il faut que les données soient dans le package, en tout cas pour des raster, car le raster contient des infos sur le tif d'origine
repertoire="data-raw/Biosim/Cartes_climat_normales/"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_climat <- list()
for (i in 1:length(liste))
{
  #cartes_climat[[i]] <- stack(paste0(repertoire,liste[[i]]))
  cartes_climat[[i]] <- terra::rast(paste0(repertoire,liste[[i]]))
}
names(cartes_climat) <- gsub(".tif","", tolower(liste)) # 22 variables
#plot(cartes_climat[[1]])
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

#save(cartes_climat, file="inst/extdata/cartes_climat.RData")
#usethis::use_data(cartes_climat, overwrite = TRUE)

# test
fic <- paste0(repertoire,liste[[1]])
aridite <- terra::rast(fic)

plot(aridite)
#usethis::use_data(aridite, overwrite = TRUE)
save(aridite, file="data/aridite.rda")
save(aridite, file="data/aridite.rdata")
writeRaster(aridite, "data/aridite.h5", overwrite=TRUE)

# save metadata
metadata <- list(xmin = xmin(aridite),xmax = xmax(aridite),ymin = ymin(aridite),ymax = ymax(aridite), crs = crs(aridite), resolution = res(aridite), nrows=nrow(aridite),ncols=ncol(aridite))
usethis::use_data(metadata, overwrite=TRUE)

# Save raster values
raster_values <- values(aridite)
usethis::use_data(raster_values, overwrite=TRUE)

usethis::use_data(metadata, raster_values,
                  internal=TRUE, overwrite = TRUE)

aridite_reconstruit <- rast(vals=raster_values,
                             nrows = metadata$nrows,
                             ncols=metadata$ncols,
                             xmin = metadata$xmin,
                             ymin = metadata$ymin,
                             xmax = metadata$xmax,
                             ymax = metadata$ymax,
                             crs = metadata$crs)
plot(aridite_reconstruit)




aridite2 <- rast(nrows=nrow(aridite),ncols=ncol(aridite), xmin = xmin(aridite),xmax = xmax(aridite),ymin = ymin(aridite),ymax = ymax(aridite),crs=crs(aridite),vals=values(aridite))
save(aridite2, file="data/aridite2.rdata")
writeRaster(aridite, "data/aridite.h5",  overwrite=TRUE)

test <- rast(nrows=108, ncols=21, xmin=0, xmax=10)
usethis::use_data(test, overwrite = TRUE)
writeRaster(test, "data/test.h5", overwrite=TRUE)

########################################################################################



########################################################################################
# Fichier des cartes de climat annuels

#repertoire="P:\\F1272\\CPF\\Biosim\\Cartes_climat_annuel\\"
# il faut que les données soient dans le package, en tout cas pour des raster, car le raster contient des infos sur le tif d'origine
repertoire="data-raw/Biosim/Cartes_climat_annuel/"
liste <- list.files(repertoire, pattern = ".tif$")

cartes_climat_an <- list()
for (i in 1:length(liste))
{
  #cartes_climat_an[[i]] <- stack(paste0(repertoire,liste[[i]]))
  cartes_climat_an[[i]] <- terra::rast(paste0(repertoire,liste[[i]]))
}
# nommer les éléments
names(cartes_climat_an) <- gsub(".tif","",liste) # enlever le .tif du nom
names(cartes_climat_an) <- tolower(gsub("RF","", names(cartes_climat_an))) # enlever le RF au début et mettre en minuscule
# "growingseasonprecipitation1980" "growingseasontmean1980" etc
# plot(cartes_climat_an[[1]])

#save(cartes_climat_an, file="inst/extdata/cartes_climat_an.RData")
usethis::use_data(cartes_climat_an, overwrite = TRUE)

########################################################################################


# tous les fichiers à mettre dans le rda
#usethis::use_data(cartes_iqs, cartes_sol, cartes_climat, cartes_climat_an,
#                  internal=TRUE, overwrite = TRUE)
