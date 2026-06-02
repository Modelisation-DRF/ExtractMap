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
#' Il y a un raster par type de variables. Les rasters sont dans des fichiers tif dans le package.
#' Les cartes de climat, d'IQS et de sols sont des rasters avec des pixels d'environ 1 km2.
#' Les cartes de climat futur sont des rasters aux 2 km2
#' Les cartes de station ont des pixels de 1 km2.

#' @param file Data frame de 3 colonnes, une ligne par point à extraire. La table peut contenir plus d'une ligne par id_pe, comme une liste d'arbres regroupés en placette. La fonction utilise les coordonnées des placettes.
#' \itemize{
#'  \item id_pe: identifiant du point
#'  \item latitude: latitude du point en degrés décimales (EPSG:4326)
#'  \item longitude: longitude du point en degrés décimales (EPSG:4326)
#'  }
#' @param liste_raster Type de cartes:
#' \itemize{
#'   \item "cartes_iqs" : iqs pontentiels
#'   \item "cartes_sol" : propriétés de sol SIIGSOL
#'   \item "cartes_climat" : climats normales 30 ans
#'   \item "cartes_climat_futur" : climat futur pour 2 RCP et 9 périodes de temps
#'   \item "cartes_station" : variables de station (pente, exposition, etc.)
#'   }
#' @param variable Vecteur contenant le nom des variables à extraire, par exemple: c("tmean","totalprecipitation")
#' \itemize{
#'   \item cartes_iqs: iqs_pot_bop, iqs_pot_pex, iqs_pot_epb, iqs_pot_epn, iqs_pot_epr, iqs_pot_pig, iqs_pot_pib, iqs_pot_tho, iqs_pot_sab
#'   \item cartes_sol : cec, mat_org, ph, sable, limon, argile
#'   \item cartes_station : pente, exposition, depot
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
#'   \item cartes_climat_futur :
#'     \itemize{
#'       \item nom d'une couche : Période_RCP_Variable, ex: 1991-2020_RCP45_Aridity
#'       \item Période:  1991-2020, 2001-2030, 2011-2040, 2021-2050, 2031-2060, 2041-2070, 2051-2080, 2061-2090, 2071-2100
#'       \item RCP: RCP45 ou RCP85
#'       \item Variable: Aridity, CMI, CMIcm, DD, FFP, MSP, Max_ST, Min_WT, PAS, PTot, PUtile, TMoy, TSummer, TmaxUtil, Tmax_yr, TotalVPD, UtilVPD
#'   }
#'   }
#' @param profondeur Profondeur pour les propriétés de sols, utilisé seulement si liste_raster="cartes_sol", 1 par défaut
#' \itemize{
#'  \item 1: profondeur 0-5 cm
#'  \item 2: profondeur 5-15 cm
#' }
#' @return  Data frame \code{file} avec les colonnes supplémentaires spécifiées dans \code{variable}
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
#' climat_futur_values <- extract_map_plot(file=fic_test, liste_raster="cartes_climat_futur", variable=c("1991-2020_RCP45_Aridity","2071-2100_RCP45_UtilVPD"))
#' }
extract_map_plot <- function(file, liste_raster, variable, profondeur=1){

  # file=fic_test; liste_raster="cartes_iqs"; variable=c("iqs_pot_epn","iqs_pot_epb","iqs_pot_pig","iqs_pot_tho","iqs_pot_pib","iqs_pot_epr","iqs_pot_sab","iqs_pot_bop","iqs_pot_pex");
  # file=fic_test; liste_raster="cartes_sol"; variable=c("cec","ph","sable","argile","mat_org","limon"); profondeur=2;
  # file=fic_test; liste_raster="cartes_climat"; variable=c("totalprecipitation","tmean");
  # file=fic_test; liste_raster="cartes_station"; variable=c("pente","exposition","depot"); profondeur=2;
  # file=fic_test; liste_raster="cartes_climat_futur"; variable=c("1991-2020_RCP45_Aridity","2071-2100_RCP45_UtilVPD");

  # vérifier les noms demandés
  nom_raster <- c("cartes_iqs", "cartes_sol", "cartes_climat", "cartes_station", "cartes_climat_futur")

  nom_climat <- c("aridity", "consecutivedayswithoutfrost", "dayswithoutfrost", "degreeday",
                  "firstfrostday", "growingseasonlength", "growingseasonprecipitation",
                  "growingseasonradiation", "growingseasontmean", "julytmean",
                  "lastfrostday", "pet", "snowfallproportion", "tmax", "tmean", "tmin",
                  "totalprecipitation", "totalradiation", "totalsnowfall",
                  "totalvpd", "utilprecipitation", "utilvpd")
  nom_sol <- c("cec","ph","mat_org","sable","limon","argile")
  nom_iqs <- c("iqs_pot_epn","iqs_pot_epb","iqs_pot_pig","iqs_pot_tho","iqs_pot_pib","iqs_pot_epr","iqs_pot_sab","iqs_pot_bop","iqs_pot_pex")
  nom_station <- c("pente","exposition","depot")
  liste_prof <- c(1,2)

  nom_climat_futur_var <- c("Aridity", "CMI", "CMIcm", "DD", "FFP", "MSP", "Max_ST", "Min_WT", "PAS", "PTot", "PUtile", "TMoy", "TSummer", "TmaxUtil", "Tmax_yr", "TotalVPD", "UtilVPD")
  nom_climat_futur_per <- c("1991-2020", "2001-2030", "2011-2040", "2021-2050", "2031-2060", "2041-2070", "2051-2080", "2061-2090", "2071-2100")
  nom_climat_futur_rcp <- c("RCP45","RCP85")
  nom_climat_futur <- apply(
      expand.grid(
        nom_climat_futur_per,
        nom_climat_futur_rcp,
        nom_climat_futur_var,
        stringsAsFactors = FALSE
      ),
      1,
      paste,
      collapse = "_"
    )

  if (length(setdiff(liste_raster, nom_raster))>0) {stop("Nom du raster demande incorrect")}
  if (liste_raster=="cartes_sol" & length(setdiff(variable, nom_sol))>0) {stop("Nom des variables de sol demandees incorrect")}
  if (liste_raster=="cartes_sol" & length(setdiff(profondeur, liste_prof))>0) {stop("Profondeur des proprietes de sol demandee incorrecte")}
  if (liste_raster=="cartes_climat" & length(setdiff(variable, nom_climat))>0) {stop("Nom des variables de climat demandees incorrect")}
  if (liste_raster=="cartes_iqs" & length(setdiff(variable, nom_iqs))>0) {stop("Nom des variables d'IQS demandees incorrect")}
  if (liste_raster=="cartes_station" & length(setdiff(variable, nom_station))>0) {stop("Nom des variables de station demandees incorrect")}
  if (liste_raster=="cartes_climat_futur" & length(setdiff(variable, nom_climat_futur))>0) {stop("Nom des variables de climat futur demandees incorrect")}

  if (sum(variable %in% names(file))>0) {stop("Variables demandees deja presentes dans le fichier")}


  # Attribuer le nom du répertoire des fichiers tif selon le type de raster
  if (liste_raster=="cartes_sol") repertoire = system.file("extdata/SIIGSOL/res_1000_x_1000m", package = "ExtractMap")
  if (liste_raster=="cartes_climat") repertoire = system.file("extdata/CLIMAT/Cartes_climat_normales", package = "ExtractMap")
  if (liste_raster=="cartes_iqs") repertoire = system.file("extdata/IQS_POT", package = "ExtractMap")
  if (liste_raster=="cartes_station") repertoire = system.file("extdata/STATION", package = "ExtractMap")
  if (liste_raster=="cartes_climat_futur") repertoire = system.file("extdata/CLIMAT/Cartes_climat_futur", package = "ExtractMap")

  # nom du fichier tif
  fichier <- list.files(repertoire, full.names = TRUE, pattern = "\\.(tif|gpkg)$", ignore.case = TRUE)

  # Lire le raster
  if (liste_raster %in% c("cartes_iqs","cartes_climat","cartes_sol","cartes_climat_futur")) cartes <- terra::rast(fichier)
  if (liste_raster=="cartes_station") {
    pente <- terra::rast(fichier[grepl("pente", basename(fichier), ignore.case = TRUE)])
    expo <- terra::rast(fichier[grepl("expo", basename(fichier), ignore.case = TRUE)])
    depot <- terra::vect(fichier[grepl("depot", basename(fichier), ignore.case = TRUE)])
    cartes <- list(pente, expo, depot) # ne peuvent pas être dans un raster multicouches car pas le même CRS
    names(cartes) <- c('pente','exposition','depot')
  }

  # Si variables de sol, ajouter la profondeur au bout du nom de la variable
  if (liste_raster=="cartes_sol") {
    prof <- '0-5'
    var <- variable
    if (profondeur==2) prof <- '5-15'
    variable <- paste(variable, prof, sep='_')
  }

  # faire une liste des coord à extraire
  liste_place <- file %>% dplyr::select(id_pe, latitude, longitude) %>%  unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- sf::st_crs(cartes[[1]]) # extract projection from a map
  pet_pe <- sf::st_as_sf(liste_place, coords = c("longitude", "latitude")) # convert un table into an sf object
  sf::st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- sf::st_transform(pet_pe, crs = proj_carte) # convert coordinates
  tous_pe <- terra::vect(tous_pe)

  # si le raster est un multicouche, on extrait toutes les variables en même temps
  if (liste_raster %in% c("cartes_iqs","cartes_climat","cartes_sol","cartes_climat_futur")) {
    extract_tous <- data.frame(terra::extract(cartes[[variable]], tous_pe)) %>% dplyr::select(-ID)

    if (liste_raster=="cartes_sol") {names(extract_tous) <- var} # si carte de sol, il faut changer le nom pour enlever la profondeur
    if (liste_raster=="cartes_climat_futur") {
      names(extract_tous) <- sub("^X", "P", names(extract_tous)) # changer le X en avant du nom par un P
      names(extract_tous) <- gsub("\\.", "_", names(extract_tous)) # changer le . par _ dans 1991.2020 pour 1991_2020
      extract_tous <- extract_tous/100 # les variables ont été *100 pour éviter les décimales dans le tif
    }
  }
  # si le raster n'est pas un multicouche, on fait une boucle sur les variables
  if (liste_raster %in% c("cartes_station")) {
    extract_tous <- NULL
    for(x in 1:length(variable)){
      fic_temp <- data.frame(terra::extract(cartes[[variable[[x]]]], tous_pe))
      extract_tous <- bind_cols(extract_tous, fic_temp[,2, drop = FALSE])
    }
  }


  # ajouter les infos placettes et ne garder que les placettes qui n'ont pas de valeurs manquantes: je vais garder les données manquantes
  liste_place <- as.data.frame(liste_place) %>% dplyr::select(id_pe)
  extract_tous2 <- bind_cols(liste_place, extract_tous) #%>% filter(complete.cases(.))

  # merger au fichier d'entree, pour aller chercher toutes les lignes s'il y avait plus d'une ligne par id_pe
  fic <- inner_join(file, extract_tous2, by='id_pe', multiple='all')

  return(fic)
}


