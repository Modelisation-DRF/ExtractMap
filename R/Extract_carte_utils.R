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


#' Extrait les valeurs d'un raster à partir de coordonnées
#'
#' @description \code{extract_point} extrait les valeurs d'un raster à partir de coordonnées.
#'
#' @param fic_carte Nom de la liste contenant les rasters
#' @param element Numéro de l'élément de la liste correspodant au raster à utiliser
#' @param couche Numéro de la couche du raster. 1 si seulement une couche
#' @param fic_points Table sf contenant les coordonnées sous forme de geométrie, dans la projection appropriée, des points à extraire. Une ligne par point, 2 colonnes, lat et long.
#'
#' @return Table avec une colonne, le nom de la colonne est la concaténation du nom du raster et de la couche.
#' @export
#'
#' @examples
#' \dontrun{
#' value <- extract_point(fic_carte=carte, element=1, couche=1, fic_points=liste_points)
#' }
extract_point <- function(fic_carte, element, couche, fic_points){
  # fic_carte = cartes_iqs
  # element=1; couche=1;
  # fic_points=tous_pe
  point_extract <- as.data.frame(raster::extract(fic_carte[[element]][[couche]], fic_points))
  if (nlayers(fic_carte[[element]])==1) {names(point_extract) <- tolower(names(fic_carte)[[element]])}
  if (nlayers(fic_carte[[element]])>1) {names(point_extract) <- tolower(paste(names(fic_carte)[[element]],names(fic_carte[[element]])[[couche]], sep='.'))}
  return(point_extract)
}



#' Extrait les valeurs de tous les rasters d'une liste à partir de coordonnées, pour une couche donnée
#'
#' @description \code{extract_carte} extrait les valeurs  de tous les rasters d'une liste à partir de coordonnées, pour une couche donnée
#'
#' @details
#' Pour chaque raster d'une liste, la fonction extrait les valeurs associées aux coordonnées des points. Les valeurs extraites de chaque raster sont regroupées dans une table, une colonne correspondant à un raster/couche
#'
#' @param liste_place Table de 3 colonnes, une ligne par point à extraire.
##' \itemize{
#'  \item id_pe: identifiant du point
#'  \item latitude: latitude du point en degrés décimales (4326)
#'  \item longitude: longitude du point en degrés décimales (4326)
#'  }
#' @param carte Nom de la liste contenant les rasters
#' @param variable Vecteur contenant le nom des variables à extraire, par exemple: c("TMean","TotalPrecipitation")
#' @param couche Le nuémro de la couche à extraire de chaque raster, 1 si seulement une couche
#'
#' @return Table avec autant de colonnes que de rasters dans \code{carte}
#' @export
#'
#' @examples
#' \dontrun{
#' sol <- extract_carte(liste_place=liste_points, carte=cartes_sol, variable=c("cec","ph"), couche=1)
#' }
extract_carte <- function(liste_place, carte, variable, couche) {

  #carte=cartes_climat; couche=1; liste_place=fic_test; variable=c("TMean","TotalPrecipitation")
  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  # sélectionner les variables à extraire

  registerDoFuture()
  plan(multisession)
  extract_tous <-
    foreach(x = 1:length(variable), .combine=cbind, .packages = c("raster",'sf')) %dopar%
    {
      # numéro de l'élément de la liste qui contient les rasters correspondant à l'élément x de variable
      element <- which(names(carte) == variable[x])
      extract_point(fic_carte=carte, element=element, couche=couche, fic_points=tous_pe)
    }
  plan(sequential)

  return(extract_tous)
}

