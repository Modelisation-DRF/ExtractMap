test_that("La fonction extract_map_plot retourne les bons noms de colonnes pour les IQS", {

  variables <- c("iqs_pot_epn","iqs_pot_epb","iqs_pot_pig","iqs_pot_tho","iqs_pot_pib","iqs_pot_epr","iqs_pot_sab","iqs_pot_bop","iqs_pot_pex")
  value <- extract_map_plot(file=fic_test, liste_raster="cartes_iqs", variable=variables)

  nom_obtenu <- names(value)[5:13]
  expect_equal(nom_obtenu, variables)

})


test_that("La fonction extract_map_plot retourne les bons noms de colonnes pour les variables de sol", {

  variables <- c("cec","ph","mat_org","sable","limon","argile")
  value <- extract_map_plot(file=fic_test, liste_raster="cartes_sol", variable=variables)

  nom_obtenu <- names(value)[5:10]
  expect_equal(nom_obtenu, variables)

})

test_that("La fonction extract_map_plot retourne les bons noms de colonnes pour les climat normal 30 ans", {

  #variables <- c("aridity", "consecutivedayswithoutfrost")
  variables <- c("aridity", "consecutivedayswithoutfrost", "dayswithoutfrost", "degreeday",
                  "firstfrostday", "growingseasonlength", "growingseasonprecipitation",
                  "growingseasonradiation", "growingseasontmean", "julytmean",
                  "lastfrostday", "pet", "snowfallproportion", "tmax", "tmean", "tmin",
                  "totalprecipitation", "totalradiation", "totalsnowfall",
                  "totalvpd", "utilprecipitation", "utilvpd")
  value <- extract_map_plot(file=fic_test, liste_raster="cartes_climat", variable=variables)

  #nom_obtenu <- names(value)[5:6]
  nom_obtenu <- names(value)[5:26]
  expect_equal(nom_obtenu, variables)

})

test_that("La fonction extract_map_plot retourne une erreur si nom des variables de climat incorrect", {
  liste_place <- fic_test
  variables <- c("aridity", "temperature")
  expect_error(extract_map_plot(file=liste_place, liste_raster="cartes_climat", variable=variables),"Nom des variables de climat demandées incorrect")
})
test_that("La fonction extract_map_plot retourne une erreur si nom des variables de sol incorrect", {
  liste_place <- fic_test
  variables <- c("cec", "clay")
  expect_error(extract_map_plot(file=liste_place, liste_raster="cartes_sol", variable=variables),"Nom des variables de sol demandées incorrect")
})
test_that("La fonction extract_map_plot retourne une erreur si nom des variables de IQS incorrect", {
  liste_place <- fic_test
  variables <- c("iqs_bop", "iqs_pot_sab")
  expect_error(extract_map_plot(file=liste_place, liste_raster="cartes_iqs", variable=variables),"Nom des variables d'IQS demandées incorrect")
})
test_that("La fonction extract_map_plot retourne une erreur si profondeur incorrecte", {
  liste_place <- fic_test
  variables <- c("cec", "argile")
  expect_error(extract_map_plot(file=liste_place, liste_raster="cartes_sol", variable=variables, profondeur = 3),"Profondeur des propriétés de sol demandée incorrecte")
})
test_that("La fonction extract_map_plot retourne une erreur si nom du raster_incorrect", {
  liste_place <- fic_test
  variables <- c("cec", "argile")
  expect_error(extract_map_plot(file=liste_place, liste_raster="cartes", variable=variables),"Nom du raster demandé incorrect")
})

test_that("La fonction extract_map_plot retourne une erreur si la variable demandée est déjà dans le fichier", {
  liste_place <- fic_test
  liste_place$cec <- 0.5
  variables <- c("cec","sable")
  expect_error(extract_map_plot(file=liste_place, liste_raster="cartes_sol", variable=variables),"Variables demandées déjà présentes dans le fichier")

})

test_that("La fonction extract_map_plot retourne la bonne valeur de climat normal 30 ans", {

  carte <- "cartes_climat"
  variable = "tmean"
  liste_place <- fic_test
  # 47.88455 , -72.64952
  # 47.43823,  -73.37042

  value1 <- extract_map_plot(file=liste_place, liste_raster=carte, variable=variable) %>% as.data.frame

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On verra apparaitre les 2 points en rouge.
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification
  #valeur_attendu <- c(2.49900, 2.12072)
  valeur_attendu <- c(2.5, 2.3) # aggrégé et arrondi à 1
  valeur_obtenu <- round(as.numeric(rbind(value1[1,5], value1[2,5])),5)

  expect_equal(valeur_obtenu, valeur_attendu)


})

test_that("La fonction extract_map_plot retourne la bonne valeur de sol", {

  carte <- "cartes_sol"
  variable = "cec" # 0-5cm
  liste_place <- fic_test
  # 47.88455 , -72.64952
  # 47.43823,  -73.37042

  value1 <- extract_map_plot(file=liste_place, liste_raster=carte, variable=variable) %>% as.data.frame

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On va dans la fenêtre de droite et on fait rechercher : on tape créer... et on choisit Créer une couche de points à partir d'une table
  # Dans la fenêtre qui apparait chsoir les champs pour x et y et cliquer sur Exécuter
  #  On verra apparaitre les 2 points en rouge.
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification

  # valeur_attendu <- c(1.814182, 1.148471) # valeurs dans la carte à resolution  100 x 100 m
  # valeur_attendu <- c(1.875036, 1.325892) # valeurs dans la carte à resolution  500 x 500 m
  #valeur_attendu <- c(1.728613, 1.375691) # valeurs dans la carte à resolution  1000 x 1000 m
  valeur_attendu <- c(1.7, 1.4) # valeurs dans la carte à resolution  1000 x 1000 m et arrondi à 1

  valeur_obtenu <-  round(as.numeric(rbind(value1[1,5], value1[2,5])),1)

  expect_equal(valeur_obtenu, valeur_attendu)

})


test_that("La fonction extract_map_plot retourne la bonne valeur d'iqs", {

  carte <- "cartes_iqs"
  variable = "iqs_pot_bop"
  liste_place <- fic_test
  # 47.88455 , -72.64952
  # 47.43823,  -73.37042

  value1 <- extract_map_plot(file=liste_place, liste_raster=carte, variable=variable) %>% as.data.frame

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On va dans la fenêtre de droite et on fait rechercher : on tape créer... et on choisit Créer une couche de points à partir d'une table
  # Dans la fenêtre qui apparait chsoir les champs pour x et y et cliquer sur Exécuter
  #  On verra apparaitre les 2 points en rouge.
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification
  #valeur_attendu <- round(c(15.466656, 15.504798),5)
  valeur_attendu <- c(15.5, 15.5) # arrondi à 1
  valeur_obtenu <- round(as.numeric(rbind(value1[1,5], value1[2,5])),1)

  expect_equal(valeur_obtenu, valeur_attendu)

})


test_that("La fonction extract_map_plot fonctionne avec la profondeur 2 pour les cartes de sol", {
  liste_place <- fic_test
  variables <- c("cec", "ph", "mat_org", "argile", "limon", "sable")
  expect_no_error(extract_map_plot(file=liste_place, liste_raster="cartes_sol", variable=variables, profondeur = 2))
})


test_that("La fonction extract_map_plot fonctionne tel qu'attendu avec une extraction de données manquantes", {
  liste_place <- fic_test
  ajout <- data.frame(id_pe='test', latitude=19.3, longitude=-70.5, an_mes=2020)
  liste_place2 <- bind_rows(liste_place, ajout)
  variables <- c("cec")
  res = extract_map_plot(file=liste_place2, liste_raster="cartes_sol", variable=variables, profondeur = 2)
  res_obt = res %>% filter(id_pe=='test')
  expect_equal(res_obt$cec,NaN)
})




