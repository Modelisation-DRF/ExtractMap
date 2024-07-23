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

#' Fonction pour extraire à partir de rasters et d'une liste de coordonnées, des variables de climat annuel et calculer la moyenne sur un nombre donnée d'années
#'
#' @description Extrait à partir de cartes de climat sous forme de raster et d'une liste de coordonnées, des variables de climat annuel et calcule la moyenne sur x années, pour les x années avant l'année spécifiée.
#'
#' @details
#' Il y a un raster par variable par année, de 1980 à 2022. Les rasters sont dans des fichiers tif dans le package.
#' Conditions: an_mes - periode >= 1980 et an_mes<=2023
#'
#' @param file Table de 4 colonnes, une ligne par point à extraire. La table peut contenir plus d'une ligne par id_pe, comme une liste d'arbres regroupés en placette. La fonction utilise les coordonnées des placettes.
#' \itemize{
#'  \item id_pe: identifiant du point
#'  \item latitude: latitude du point en degrés décimales (4326)
#'  \item longitude: longitude du point en degrés décimales (4326)
#'  \item an_mes: année correspondant à la fin de la période
#'  }
#' @param variable Vecteur contenant le nom des variables à extraire (sans l'année), par exemple: c("growingseasonprecipitation","growingseasontmean"). Variables disponibles:
#' \itemize{
#'  \item growingseasonprecipitation
#'  \item growingseasontmean
#'  }
#' @param periode Nombre d'années dans la période pour calculer la moyenne. Par exemple, si an_mes=2007, une période de 10 ans sera la moyenne de 1997 à 2006. Par défaut=10. Maximum 10.
#'
#' @return Table \code{file} avec les colonnes supplémentaires spécifiées dans \code{variable}
#' @export
#'
#' @examples
#' \dontrun{
#' climate_values <- extract_climat_an(file=fic_test, variable=c("growingseasonprecipitation","growingseasontmean"))
#' }
extract_climat_an <- function(file, variable, periode=10) {

  # file=fic_test %>%  mutate(an_mes=2023); variable=c("growingseasonprecipitation","growingseasontmean"); periode=10;
  # periode=2; file = fic_test %>% mutate(an_mes=1975) %>% filter(id_pe=='0700200501_N_1970'); variable = "growingseasontmean";
  # periode=2; file = fic_test %>% mutate(an_mes=2025) %>% filter(id_pe=='0700200501_N_1970'); variable = "growingseasontmean";
  # file=fic_test; variable=c("growingseasonprecipitation","growingseasontmean");  periode=10

  if (periode > 10 ) {stop("periode ne doit pas être supérieure à 10")}

  nom_climat_an <- c("growingseasonprecipitation","growingseasontmean")
  if (length(setdiff(variable, nom_climat_an))>0) {stop("Nom des variables de climat annuel demandées incorrect")}
  if (sum(variable %in% names(file))>0) {stop("Variables demandées déjà présentes dans le fichier")}

  # il y a une seule couche
  couche =1

  liste_place <- file %>% dplyr::select(id_pe, latitude, longitude, an_mes) %>%  unique()

  # limiter le nombre de raster à extraire, aller chercher l'année de mesure minimale et maximal et enlever 10 ans
  an_min <- min(liste_place$an_mes)-periode
  an_max <- max(liste_place$an_mes)-1

  if (an_min < 1980) {stop("an_mes-periode ne doit pas être inférieure à 1980")}
  if (an_max > 2022 ) {stop("an_mes ne doit pas être supérieure 2023")}

  # je ne ferai pas ça pour l'instant
  # if (an_min < 1970) {stop("an_mes-periode ne doit pas être inférieur à 1970")} # je tolère max de 10 ans en bas de 1980
  # if (an_max > 2024 ) {stop("an_mes ne doit pas être supérieur 2025")} # je tolère max 2 ans en haut de 2022
  #
  # # pour aller chercher les cartes des bonnes années
  # if ((an_min-periode)<1980) {
  #   an_min <- 1980
  #   if (an_max<1980) an_max <- 1980+periode-1
  #   }
  # if (an_max>2022) {
  #   an_max <- 2022
  #   if (an_min>2022) an_min <- 2022-periode
  #   }

  # ajouter toutes les années aux noms des éléments de variable
  variable_tous <- NULL
  for (i in an_min:an_max){
    for (j in 1:length(variable)){
      var_ij <- paste0("RF",variable[j],i)
      variable_tous <- c(variable_tous, var_ij)
    }
  }
  # lire les fichiers tif
  repertoire = system.file("extdata/CLIMAT/Cartes_climat_annuel/", package = "ExtractMap")
  cartes <- list()
  for (i in 1:length(variable_tous))
  { # i=1
    cartes[[i]] <- terra::rast(paste0(repertoire,"/",variable_tous[[i]],".tif"))
  }
  names(cartes) <- gsub(".tif","",variable_tous) # enlever le .tif du nom
  names(cartes) <- tolower(gsub("RF","", names(cartes))) # enlever le RF au début et mettre en minuscule
  #plot(cartes[[1]])

  # transform the coordinates in the same projection as the maps
  proj_carte <- sf::st_crs(cartes[[1]]) # extract projection from a map
  pet_pe <- sf::st_as_sf(liste_place, coords = c("longitude", "latitude")) # convert un table into an sf object
  sf::st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- sf::st_transform(pet_pe, crs = proj_carte) # convert coordinates

  extract_tous <- NULL
  for(x in 1:length(variable_tous)){
    # x=1
    fic_temp <- as.data.frame(terra::extract(cartes[[x]][[couche]], tous_pe))
    if (x==1) extract_tous <- fic_temp
    if (x>1) extract_tous <- left_join(extract_tous, fic_temp, by='ID')
  }
  extract_tous <- extract_tous %>% dplyr::select(-ID)
  names(extract_tous) <- tolower(names(extract_tous))

  # calculer la moyenne sur la période
  clim_plot2 <- bind_cols(liste_place, extract_tous) %>% dplyr::select(-latitude,-longitude) %>%
    group_by(id_pe, an_mes) %>%
    pivot_longer(names_to = "nom", values_to = "climat", cols = contains(variable_tous)) %>% # select only variables in parameter variable
    mutate(annee = as.numeric(substr(nom, str_length(nom)-3,str_length(nom))),
           nom = substr(nom, 3, str_length(nom)-4), # il y a RF au début
           # je veux que la fct marche tout le temps, alors si an_mes trop vieille, prendre toujours l'intervalle 1980 à 1980+periode
           # si an_mes trop récente, toujours prendre l'intervalle avec fin en 2022
           # an_mes2 = ifelse(an_mes-periode < 1980, 1980+periode,
           #                  ifelse(an_mes > 2023, 2023,
           #                         an_mes)),
           an_mes2=an_mes,

           climat2 = ifelse(annee>=an_mes2, NA,
                            ifelse(annee<an_mes2-periode, NA, climat))) %>%
    group_by(id_pe, nom) %>%
    summarise(moy = mean(climat2, na.rm=TRUE),
              .groups="drop_last") %>%
    group_by(id_pe) %>%
    pivot_wider(names_from = "nom", values_from = "moy") %>%
    ungroup()

  # ne garder que les placettes qui ont des valeurs de climat partout
  clim_plot3 <- clim_plot2 %>% filter(complete.cases(.))

  # merger au fichier d'entree pour rajouter les lignes s'il y avait plus d'une lignes par placette
  fic <- inner_join(file, clim_plot3, by='id_pe', multiple='all')
  return(fic)
}





# dans la calibration de natura, c'est la moyenne des 10 années dans l'intervalle entre 2 mesures,
# donc ce sont les 10 ans suivant le début de l'intervalle.
# en théorie, j'aurais du faire ici la moyenne des 10 ans suivant la mesure, donc si an_mes=2022, faire 2022 à 2032, mais je n'ai pas le cliamt des années futures
# ici, je fais donc la moyenne des 10 ans avant le debut de l'intervalle, et les années disponibles sont 1980 à 2022,
# donc il faut une mesure entre 1990 et 2023, sinon ça ne fonctionnera pas.
# mais je pourrais implanter des contitions pour que ça fonctionne toujours:
# si an_mes<=1989, toujours prendre les années 1980 à 1989
# si an_mes>=2024, toujours prednre les années 2013 à 2022

# ancienne façon
# id_pe                prec_gs temp_gs
# 1 0700200501_N_1970    467.    14.4
# 2 1419610501_N_1922    503.    14.6

# avec ma nouvelle façon
# id_pe               growingseasonprecipitation growingseasontmean
# 1 0700200501_N_1970                       467.               14.4
# 2 1419610501_N_1922                       503.               14.6

