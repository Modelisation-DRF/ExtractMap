# Le fichier des cartes de climat futur contient une couche par variable climatique/période/SSP
# Mais pour la période 1991-2020, il n'y a pas de SSP, c'est écrit NA: "1991-2020_NA_Aridity"
# Il faut dédoubler toutes les couches de la période 1991-2020 et en appeler une avec SSP245 et une autre avec SSP370
library(tidyverse)
repertoire = system.file("data-raw/Cartes_climat_futur", package = "ExtractMap")
fichier <- list.files(repertoire, full.names = TRUE, pattern = "\\.(tif|gpkg)$", ignore.case = TRUE)
cartes <- terra::rast(fichier)
names(cartes)
#[1] "1991-2020_NA_Aridity"      "1991-2020_NA_CMI"          "1991-2020_NA_CMIcm"        "1991-2020_NA_DD"           "1991-2020_NA_FFP"          "1991-2020_NA_MSP"
#[7] "1991-2020_NA_Max_ST"       "1991-2020_NA_Min_WT"       "1991-2020_NA_PAS"          "1991-2020_NA_PTot"         "1991-2020_NA_PUtile"       "1991-2020_NA_TMoy"
#[13] "1991-2020_NA_TSummer"      "1991-2020_NA_TmaxUtil"     "1991-2020_NA_Tmax_yr"      "1991-2020_NA_TotalVPD"     "1991-2020_NA_UtilVPD"

# Garder les 17 premieres colonnes
carte_1991_2020 <- cartes[[1:17]]
# changer le nom des couches
carte_1991_2020_SSP245 <- carte_1991_2020
carte_1991_2020_SSP370 <- carte_1991_2020
nom_ssp245 <- names(carte_1991_2020)
nom_ssp245 <- str_replace(nom_ssp245, "_NA_", "_SSP245_")
nom_ssp370 <- names(carte_1991_2020)
nom_ssp370 <- str_replace(nom_ssp370, "_NA_", "_SSP370_")

names(carte_1991_2020_SSP245) <- nom_ssp245
names(carte_1991_2020_SSP370) <- nom_ssp370

verif <- carte_1991_2020_SSP245[1:2,] # ok

# enlever les 17 premieres colonnes de la carte
cartes2 <- cartes[[18:terra::nlyr(cartes)]]
terra::nlyr(cartes) # 289
terra::nlyr(cartes2) # 272
terra::nlyr(carte_1991_2020_SSP245) # 17

# ajouter les nouvelles couches
new_couches <- c(carte_1991_2020_SSP245, carte_1991_2020_SSP370)
terra::nlyr(new_couches) # 34
cartes3 <- c(new_couches, cartes2)
terra::nlyr(cartes3) # 306, ok 272+34

names(cartes3) # ok

repertoire = system.file("extdata/CLIMAT/Cartes_climat_futur", package = "ExtractMap")
terra::writeRaster(cartes3,
            paste0(repertoire,"/Climat_futur_20261001.tif"),
            overwrite=TRUE,
            datatype="INT4S",
            gdal=c(
              "COMPRESS=DEFLATE",
              "PREDICTOR=2",
              "ZLEVEL=9",
              "TILED=YES"
            ))


