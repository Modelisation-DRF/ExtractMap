test_that("La fonction extract_point retourne les bons noms de colonnes pour les IQS", {

  carte <- cartes_iqs
  couche <- 1
  liste_place <- fic_test
  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  value1 <- extract_point(fic_carte=carte, element=1, couche=couche, fic_points=tous_pe)
  value2 <- extract_point(fic_carte=carte, element=2, couche=couche, fic_points=tous_pe)
  value3 <- extract_point(fic_carte=carte, element=3, couche=couche, fic_points=tous_pe)
  value4 <- extract_point(fic_carte=carte, element=4, couche=couche, fic_points=tous_pe)
  value5 <- extract_point(fic_carte=carte, element=5, couche=couche, fic_points=tous_pe)
  value6 <- extract_point(fic_carte=carte, element=6, couche=couche, fic_points=tous_pe)
  value7 <- extract_point(fic_carte=carte, element=7, couche=couche, fic_points=tous_pe)
  value8 <- extract_point(fic_carte=carte, element=8, couche=couche, fic_points=tous_pe)
  value9 <- extract_point(fic_carte=carte, element=9, couche=couche, fic_points=tous_pe)


  nom_obtenu <- c(names(value1), names(value2), names(value3), names(value4), names(value5), names(value6), names(value7), names(value8), names(value9))
  expect_equal(nom_obtenu, names(carte))

})


test_that("La fonction extract_point retourne les bons noms de colonnes pour les variables de sol", {

  carte <- cartes_sol
  couche <- 2
  liste_place <- fic_test
  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  value1 <- extract_point(fic_carte=carte, element=1, couche=couche, fic_points=tous_pe)
  value2 <- extract_point(fic_carte=carte, element=2, couche=couche, fic_points=tous_pe)
  value3 <- extract_point(fic_carte=carte, element=3, couche=couche, fic_points=tous_pe)
  value4 <- extract_point(fic_carte=carte, element=4, couche=couche, fic_points=tous_pe)
  value5 <- extract_point(fic_carte=carte, element=5, couche=couche, fic_points=tous_pe)
  value6 <- extract_point(fic_carte=carte, element=6, couche=couche, fic_points=tous_pe)

  nom_obtenu <- c(names(value1), names(value2), names(value3), names(value4), names(value5), names(value6))
  nom_couche <- tolower(names(carte[[1]])[[2]])
  nom_attendu <- c(paste(names(carte)[[1]], nom_couche, sep='.'), paste(names(carte)[[2]], nom_couche, sep='.'), paste(names(carte)[[3]], nom_couche, sep='.'), paste(names(carte)[[4]], nom_couche, sep='.'), paste(names(carte)[[5]], nom_couche, sep='.'), paste(names(carte)[[6]], nom_couche, sep='.'))
  expect_equal(nom_obtenu,nom_attendu)

})


test_that("La fonction extract_point retourne les bons noms de colonnes pour les climat annuel", {

  carte <- cartes_climat_an # 86 élements dans la liste, 43 pour temp et 43 pout prec, une par année de 1980 à 2022
  couche <- 1
  liste_place <- fic_test
  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  value1 <- extract_point(fic_carte=carte, element=10, couche=couche, fic_points=tous_pe) # growingseasonprecipitation1989
  value2 <- extract_point(fic_carte=carte, element=52, couche=couche, fic_points=tous_pe) # growingseasonTmean1988

  nom_obtenu <- c(names(value1), names(value2))
  expect_equal(nom_obtenu, tolower(c('growingseasonprecipitation1989','growingseasonTmean1988')))

})

test_that("La fonction extract_point retourne les bons noms de colonnes pour les climat normal 30 ans", {

  carte <- cartes_climat # 2 élements dans la liste
  couche <- 1
  liste_place <- fic_test
  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  value1 <- extract_point(fic_carte=carte, element=1, couche=couche, fic_points=tous_pe)
  value2 <- extract_point(fic_carte=carte, element=2, couche=couche, fic_points=tous_pe)

  nom_obtenu <- c(names(value1), names(value2))

  expect_equal(nom_obtenu, c("aridity", "consecutivedayswithoutfrost"))

})


test_that("La fonction extract_point retourne la bonne valeur de climat normal 30 ans", {

  carte <- cartes_climat # 2 élements dans la liste
  couche <- 1
  liste_place <- fic_test
  # 47.88455 , -72.64952
  # 47.43823,  -73.37042


  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  #names(carte) tmean est l'élément 15
  value1 <- extract_point(fic_carte=carte, element=15, couche=couche, fic_points=tous_pe) # tmean

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On verra apparaitre les 2 points en rouge.
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification
  valeur_attendu <- rbind(2.49900, 2.12072)
  valeur_obtenu <- round(rbind(value1[1,1], value1[2,1]),5)

  expect_equal(valeur_obtenu, valeur_attendu)


})

test_that("La fonction extract_point retourne la bonne valeur de sol", {

  carte <- cartes_sol
  couche <- 1
  liste_place <- fic_test
  # 47.88455 , -72.64952
  # 47.43823,  -73.37042

  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  value1 <- extract_point(fic_carte=carte, element=1, couche=couche, fic_points=tous_pe) # cec 0-5cm

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On va dans la fenêtre de droite et on fait rechercher : on tape créer... et on choisit Créer une couche de points à partir d'une table
  # Dans la fenêtre qui apparait chsoir les champs pour x et y et cliquer sur Exécuter
  #  On verra apparaitre les 2 points en rouge.
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification
  valeur_attendu <- rbind(1.814182, 1.148471)
  valeur_obtenu <- round(rbind(value1[1,1], value1[2,1]),6)

  expect_equal(valeur_obtenu, valeur_attendu)

})


test_that("La fonction extract_point retourne la bonne valeur d'iqs", {

  carte <- cartes_iqs
  couche <- 1
  liste_place <- fic_test
  # 47.88455 , -72.64952
  # 47.43823,  -73.37042

  pet <- liste_place %>% dplyr::select(id_pe, latitude, longitude) %>% unique()

  # transform the coordinates in the same projection as the maps
  proj_carte <- st_crs(carte[[1]]) # extract projection from a map IA: remplacé crs par st_crs
  pet_pe <- st_as_sf(pet, coords = c(3, 2)) # convert un table into an sf object
  st_crs(pet_pe) <- 4326  # set coordinate reference system to an object, decimal degrees
  tous_pe <- st_transform(pet_pe, crs = proj_carte) # convert coordinates

  value1 <- extract_point(fic_carte=carte, element=1, couche=couche, fic_points=tous_pe) # bop

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On va dans la fenêtre de droite et on fait rechercher : on tape créer... et on choisit Créer une couche de points à partir d'une table
  # Dans la fenêtre qui apparait chsoir les champs pour x et y et cliquer sur Exécuter
  #  On verra apparaitre les 2 points en rouge.
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification
  valeur_attendu <- round(rbind(15.466656, 15.504798),5)
  valeur_obtenu <- round(rbind(value1[1,1], value1[2,1]),5)

  expect_equal(valeur_obtenu, valeur_attendu)

})

# pas besoin de tester un climat annuel, car meme type de carte que climat 30 ans
