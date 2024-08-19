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


#' Fonction pour effectuer des extractions à partir de raster et d'une liste de coordonnées
#'
#' @description Extrait des valeurs à partir de raster et d'une liste de coordonnées
#'
#' @details
#' Il y a un raster par variable. Les rasters sont dans des fichiers tif dans le package.
#' Les cartes de climat, d'IQS et de sols sont des rasters avec des pixels de 1 km2. Les cartes de station ont des pixels de 500 m2.

#' @param file Table de 3 colonnes, une ligne par point à extraire. La table peut contenir plus d'une ligne par id_pe, comme une liste d'arbres regroupés en placette. La fonction utilise les coordonnées des placettes.
#' \itemize{
#'  \item id_pe: identifiant du point
#'  \item latitude: latitude du point en degrés décimales (4326)
#'  \item longitude: longitude du point en degrés décimales (4326)
#'  }
#' @param liste_raster Type de cartes:
#' \itemize{
#'   \item "cartes_iqs" : iqs pontentiels
#'   \item "cartes_sol" : propriétés de sol SIIGSOL
#'   \item "cartes_climat" : climats normales 30 ans
#'   \item "cartes_station" : variables de station (pente, exposition, etc.)
#'   }
#' @param variable Vecteur contenant le nom des variables à extraire, par exemple: c("tmean","totalprecipitation")
#' \itemize{
#'   \item cartes_iqs: iqs_pot_bop, iqs_pot_pex, iqs_pot_epb, iqs_pot_epn, iqs_pot_epr, iqs_pot_pig, iqs_pot_pib, iqs_pot_tho, iqs_pot_sab
#'   \item cartes_sol : cec, mat_org, ph, sable, limon, argile
#'   \item cartes_station : pente, exposition
#'   \item cartes_climat :
#'     \itemize{
#'   \item aridity
#'   \item consecutivedayswithoutfrost
#'   \item dayswithoutfrost
#'   \item degreeday
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
#' @param profondeur Profondeur pour les propriétés de sols, utilisé seulement si liste_raster="cartes_sol", 1 par défaut
#' \itemize{
#'  \item 1: profondeur 0-5 cm
#'  \item 2: pronfondeur 5-15 cm
#' }
#' @return  Table \code{file} avec les colonnes supplémentaires spécifiées dans \code{variable}
#'
#'
#' @export
#'
#' @examples
#' \dontrun{
#' soil_values <- extract_map_plot(file=fic_test, liste_raster="cartes_sol", variable=c("cec","mat_org"))
#' iqs_values <- extract_map_plot(file=fic_test, liste_raster="cartes_iqs", variable=c("iqs_pot_bop","iqs_pot_epn"))
#' climat_values <- extract_map_plot(file=fic_test, liste_raster="cartes_climat", variable=c("tmean","totalprecipitation"))
#' station_values <- extract_map_plot(file=fic_test, liste_raster="cartes_station", variable=c("pente","exposition"))
#' }
extract_map_plot <- function(file, liste_raster, variable, profondeur=1){

  # file=fic_test; liste_raster="cartes_iqs"; variable=c("iqs_pot_epn","iqs_pot_epb","iqs_pot_pig","iqs_pot_tho","iqs_pot_pib","iqs_pot_epr","iqs_pot_sab","iqs_pot_bop","iqs_pot_pex");
  # file=fic_test; liste_raster="cartes_sol"; variable=c("cec","ph","sable","argile","mat_org","limon");
  # file=fic_test; liste_raster="cartes_climat"; variable=c("totalprecipitation","tmean");
  # file=fic_test; liste_raster="cartes_station"; variable=c("pente","exposition");

  # vérifier les noms demandés
  nom_raster <- c("cartes_iqs", "cartes_sol", "cartes_climat", "cartes_station")

  nom_climat <- c("aridity", "consecutivedayswithoutfrost", "dayswithoutfrost", "degreeday",
                  "firstfrostday", "growingseasonlength", "growingseasonprecipitation",
                  "growingseasonradiation", "growingseasontmean", "julytmean",
                  "lastfrostday", "pet", "snowfallproportion", "tmax", "tmean", "tmin",
                  "totalprecipitation", "totalradiation", "totalsnowfall",
                  "totalvpd", "utilprecipitation", "utilvpd")
  nom_sol <- c("cec","ph","mat_org","sable","limon","argile")
  nom_iqs <- c("iqs_pot_epn","iqs_pot_epb","iqs_pot_pig","iqs_pot_tho","iqs_pot_pib","iqs_pot_epr","iqs_pot_sab","iqs_pot_bop","iqs_pot_pex")
  nom_station <- c("pente","exposition")
  liste_prof <- c(1,2)

  if (length(setdiff(liste_raster, nom_raster))>0) {stop("Nom du raster demandé incorrect")}
  if (liste_raster=="cartes_sol" & length(setdiff(variable, nom_sol))>0) {stop("Nom des variables de sol demandées incorrect")}
  if (liste_raster=="cartes_sol" & length(setdiff(profondeur, liste_prof))>0) {stop("Profondeur des propriétés de sol demandée incorrecte")}
  if (liste_raster=="cartes_climat" & length(setdiff(variable, nom_climat))>0) {stop("Nom des variables de climat demandées incorrect")}
  if (liste_raster=="cartes_iqs" & length(setdiff(variable, nom_iqs))>0) {stop("Nom des variables d'IQS demandées incorrect")}
  if (liste_raster=="cartes_station" & length(setdiff(variable, nom_station))>0) {stop("Nom des variables de station demandées incorrect")}

  if (sum(variable %in% names(file))>0) {stop("Variables demandées déjà présentes dans le fichier")}


  # il y a une seule couche dans chacun des rasters
  couche =1

  # lire les fichiers tif
  if (liste_raster=="cartes_sol" & profondeur==1) repertoire = system.file("extdata/SIIGSOL/res_1000_x_1000m/0_5cm/", package = "ExtractMap")
  if (liste_raster=="cartes_sol" & profondeur==2) repertoire = system.file("extdata/SIIGSOL/res_1000_x_1000m/05_15cm/", package = "ExtractMap")
  if (liste_raster=="cartes_climat") repertoire = system.file("extdata/CLIMAT/Cartes_climat_normales/", package = "ExtractMap")
  if (liste_raster=="cartes_iqs") repertoire = system.file("extdata/IQS_POT/", package = "ExtractMap")
  if (liste_raster=="cartes_station") repertoire = system.file("extdata/STATION/", package = "ExtractMap")

  cartes <- list()
  for (i in 1:length(variable))
  { # i=1
    cartes[[i]] <- terra::rast(paste0(repertoire,"/",variable[[i]],".tif"))
  }
  names(cartes) <- tolower(variable)
  #plot(cartes[[1]])
  #max(cartes[[9]])
  #min(cartes[[1]])

  # faire une liste des coord à extraire
  liste_place <- file %>% dplyr::select(id_pe, latitude, longitude) %>%  unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- sf::st_crs(cartes[[1]]) # extract projection from a map
  pet_pe <- sf::st_as_sf(liste_place, coords = c("longitude", "latitude")) # convert un table into an sf object
  sf::st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- sf::st_transform(pet_pe, crs = proj_carte) # convert coordinates

  extract_tous <- NULL
  for(x in 1:length(variable)){
     # x=1
     fic_temp <- as.data.frame(terra::extract(cartes[[x]][[couche]], tous_pe))
     if (liste_raster=="cartes_sol") {names(fic_temp)[2] <- variable[x]} # si carte de sol, il faut changer le nom, car c'est le nom de la profondeur et non celui de l'élément
     if (liste_raster=="cartes_station") {names(fic_temp)[2] <- variable[x]}
     if (x==1) extract_tous <- fic_temp
     if (x>1) extract_tous <- left_join(extract_tous, fic_temp, by='ID')
  }
  extract_tous <- extract_tous %>% dplyr::select(-ID)
  names(extract_tous) <- tolower(names(extract_tous))

  # ajouter les infos placettes et ne garder que les placettes qui n'ont pas de valeurs manquantes: je vais garder les données manquantes
  liste_place <- as.data.frame(liste_place) %>% dplyr::select(id_pe)
  extract_tous2 <- bind_cols(liste_place, extract_tous) #%>% filter(complete.cases(.))

  # merger au fichier d'entree, pour aller chercher toutes les lignes s'il y avait plus d'une ligne par id_pe
  fic <- inner_join(file, extract_tous2, by='id_pe', multiple='all')

  return(fic)
}


