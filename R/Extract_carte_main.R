################################################################
#   ISABELLE AUGER                                             #
#                                                              #
#   isabelle.augere@mrnf.gouv.qc.ca                            #
#    last udate       July 2023                                #
#                                                              #
#                                                              #
#   Functions use to extract values from a map                 #
#                                                              #
#                                                              #
################################################################

#' Fonction principale pour extraire à partir de rasters et d'une liste de coordonnées, des variables de climat annuel et calculer la moyenne sur un nombre d'années donné
#'
#' @description Extrait à partir de cartes de climat sous forme de raster et d'une liste de coordonnées, des variables de climat annuel et calcule la moyenne sur un nombre donné d'années, pour les x années avant l'année spécifiée.
#'
#' @details
#' Il y a un raster par variable par année, de 1980 à 2022. Les rasters sont dans une liste et sont nommés : RFGrowingSeasonPrecipitation1980 à RFGrowingSeasonPrecipitation2022, RFGrowingSeasonTmean1980 à RFGrowingSeasonTmean2022.
#'
#' @param file Table de 4 colonnes, une ligne par point à extraire. La table peut contenir plus d'une ligne par id_pe, comme une liste d'arbres regroupés en placette. La fonction utilise les coordonnées des placettes.
#' \itemize{
#'  \item id_pe: identifiant du point
#'  \item latitude: latitude du point en degrés décimales (4326)
#'  \item longitude: longitude du point en degrés décimales (4326)
#'  \item an_mes: année correspondant à la fin de la période
#'  }
#' @param liste_raster Nom de la liste contenant les rasters, par défault=cartes_climat_an
#' @param variable Vecteur contenant le nom des variables à extraire (sans l'année), par exemple: c("growingseasonprecipitation","growingseasontmean"). Variables disponibles:
#' \itemize{
#'  \item growingseasonprecipitation
#'  \item growingseasontmean
#'  }
#' @param couche Le numéro de la couche à extraire de chaque raster, par défaut=1
#' @param periode Nombre d'années pour calculer la moyenne sur la période. Par exemple, si an_mes=2007, une période de 10 ans sera la moyenne de 997 à 2006. Par défaut=10.
#'
#' @return Table \code{file} avec les colonnes supplémentaires spécifiées dans \code{variable}
#' @export
#'
#' @examples
#' \dontrun{
#' climate_values <- extract_climat_an(file=fic_test, variable=c("growingseasonprecipitation","growingseasontmean"))
#' }
extract_climat_an <- function(file, liste_raster=cartes_climat_an, variable, couche=1, periode=10) {

  # liste_raster=cartes_climat_an; variable=c("growingseasonprecipitation","growingseasontmean"); couche=1; file=fic_test; periode=10;
  liste_place <- file %>% dplyr::select(id_pe, latitude, longitude, an_mes) %>%  unique()

  # limiter le nombre de raster à extraire, aller chercher l'année de mesure minimale et maximal et enlever 10 ans
  an_min <- min(liste_place$an_mes)-periode
  an_max <- max(liste_place$an_mes)-1

  if (an_min < 1980) {stop("an_mes - periode ne doit pas être inférieurà 1980")}
  if (an_max > 2022 ) {stop("an_mes ne doit pas être supérieur 2023")}

  # ajouter toutes les années aux noms des éléments de variable
  variable_tous <- NULL
  for (i in an_min:an_max){
    for (j in 1:length(variable)){
      var_ij <- paste0(variable[j],i)
      variable_tous <- c(variable_tous, var_ij)
    }
  }
  clim_plot <- extract_carte(liste_place=liste_place, carte=liste_raster, variable=variable_tous, couche=1)

  clim_plot2 <- bind_cols(liste_place, clim_plot) %>% dplyr::select(-latitude,-longitude) %>%
    group_by(id_pe, an_mes) %>%
    pivot_longer(names_to = "nom", values_to = "climat", cols = contains(variable)) %>% # select only variables in parameter variable
    mutate(annee = as.numeric(substr(nom, str_length(nom)-3,str_length(nom))),
           nom = substr(nom, 1, str_length(nom)-4), # il n'y a plus RF au début
           #nom2 = ifelse(grepl("precipitation",nom)==TRUE, "prec_gs",
           #              ifelse(grepl("tmean",nom)==TRUE, "temp_gs", nom)),
           climat2 = ifelse(annee>=an_mes, NA,
                            ifelse(annee<an_mes-periode, NA, climat))) %>%
    group_by(id_pe,nom) %>%
    summarise(moy = mean(climat2, na.rm=TRUE),
              .groups="drop_last") %>%
    group_by(id_pe) %>%
    pivot_wider(names_from = "nom", values_from = "moy") %>%
    ungroup()
  #names(clim_plot2) <- gsub("rf","",names(clim_plot2))

  # ne garder que les placettes qui ont des valeurs de climat partout
  clim_plot3 <- clim_plot2 %>% filter(complete.cases(.))

  # merger au fichier d'entree
  fic <- inner_join(file, clim_plot3, by='id_pe', multiple='all')
  return(fic)
}

# ancienne façon
# id_pe                prec_gs temp_gs
# 1 0700200501_N_1970    467.    14.4
# 2 1419610501_N_1922    503.    14.6

# avec ma nouvelle façon
# id_pe               growingseasonprecipitation growingseasontmean
# 1 0700200501_N_1970                       467.               14.4
# 2 1419610501_N_1922                       503.               14.6

#' Fonction principale pour effectuer des extractions à partir de raster et d'une liste de coordonnées
#'
#' @description Extrait des valeurs à partir de raster et d'une liste de coordonnées
#'
#' @param file Table de 3 colonnes, une ligne par point à extraire. La table peut contenir plus d'une ligne par id_pe, comme une liste d'arbres regroupés en placette. La fonction utilise les coordonnées des placettes.
#' \itemize{
#'  \item id_pe: identifiant du point
#'  \item latitude: latitude du point en degrés décimales (4326)
#'  \item longitude: longitude du point en degrés décimales (4326)
#'  }
#' @param liste_raster Nom de la liste contenant les rasters
#' \itemize{
#'   \item cartes_iqs : iqs pontentiels
#'   \item cartes_sol : propriétés de sol SIIGOLS
#'   \item cartes_climat : climats normales 30 ans
#'   }
#' @param variable Vecteur contenant le nom des variables à extraire, par exemple: c("tmean","totalprecipitation")
#' \itemize{
#'   \item cartes_iqs: iqs_pot_bop, iqs_pot_pex, iqs_pot_epb, iqs_pot_epn, iqs_pot_epr, iqs_pot_pig, iqs_pot_pib, iqs_pot_tho, iqs_pot_sab
#'   \item cartes_sol : cec, oc, ph, sand, silt, clay
#'   \item cartes_climat :
#'     \itemize{
#'   \item aridity
#'   \item consecutiveDayswithoutfrost
#'   \item dayswithoutfrost degreeday
#'   \item firstfrostday
#'   \item growingseasonlength
#'   \item growingseasonprecipitation
#'   \item growingseasonradiation
#'   \item growingseasontmean
#'   \item julytmean
#'   \item lastfrostday
#'   \item pet
#'   \item snowfallproportion
#'   \item tmax
#'   \item tmean
#'   \item tmin
#'   \item totalprecipitation
#'   \item totalradiation
#'   \item totalsnowfall
#'   \item totalvpd
#'   \item utilprecipitation
#'   \item utilvpd
#'   }
#'   }
#' @param couche Le nuémro de la couche à extraire de chaque raster
#' \itemize{
#'   \item Pour cartes_iqs, une seule couche
#'   \item Pour cartes_sol, 6 couches (1: 0-5cm, 2: 5-15cm, 3: 15-30cm, 4: 30-60cm, 5: 60-100cm, 6: 100-200cm)
#'   \item Pour cartes_climat, une seule couche
#'   }
#'
#' @return  Table \code{file} avec les colonnes supplémentaires spécifiées dans \code{variable}
#' @export
#'
#' @examples
#' \dontrun{
#' soil_values <- extract_map_plot(file=fic_test, liste_raster=cartes_sol, variable=c("cec","oc"), couche=1)
#' iqs_values <- extract_map_plot(file=fic_test, liste_raster=cartes_iqs, variable=c("iqs_pot_bop","iqs_pot_epn"), couche=1)
#' climat_values <- extract_map_plot(file=fic_test, liste_raster=cartes_climat, variable=c("tmean","totalprecipitation"), couche=1)
#' }
extract_map_plot <- function(file, liste_raster, variable, couche){

  liste_place <- file %>% dplyr::select(id_pe, latitude, longitude) %>%  unique()

  plot_extract <- extract_carte(liste_place=liste_place, carte=liste_raster, variable=variable, couche=couche)

  # ajouter les infos placettes et ne garder que les placettes qui n'ont pas de valeurs manquantes
  liste_place <- as.data.frame(liste_place) %>% dplyr::select(id_pe)
  plot_extract2 <- bind_cols(liste_place,plot_extract) %>%
    filter(complete.cases(.))

  # merger au fichier d'entree
  fic <- inner_join(file, plot_extract2, by='id_pe', multiple='all')
  return(fic)
}


