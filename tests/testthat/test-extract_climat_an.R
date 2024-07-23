test_that("La fonction extract_climat_an retourne les bons noms de colonnes pour les climat annuel", {

  liste_place <- fic_test
  variables <- c("growingseasonprecipitation","growingseasontmean")
  value <- extract_climat_an(file=liste_place, variable=variables)

  nom_obtenu <- names(value)[5:6]
  expect_equal(nom_obtenu, variables)

})

test_that("La fonction extract_climat_an retourne une erreur si nom des variables de climat annuel incorrect", {
  liste_place <- fic_test
  variables <- c("growingseasonprecipitation", "temperature")
  expect_error(extract_climat_an(file=liste_place, variable=variables),"Nom des variables de climat annuel demandées incorrect")
})
test_that("La fonction extract_climat_an retourne une erreur si la variable demandée est déjà dans le fichier", {
  liste_place <- fic_test
  liste_place$growingseasonprecipitation <- 200
  variables <- c("growingseasonprecipitation", "growingseasontmean")
  expect_error(extract_climat_an(file=liste_place, variable=variables),"Variables demandées déjà présentes dans le fichier")

})
test_that("La fonction extract_climat_an retourne une erreur si periode>10", {
  liste_place <- fic_test
  periode=15
  variables <- c("growingseasonprecipitation")
  expect_error(extract_climat_an(file=liste_place, variable=variables, periode=periode),"periode ne doit pas être supérieure à 10")
})
# test_that("La fonction extract_climat_an retourne une erreur an_mes-1 > 2024", {
#   liste_place <- fic_test %>% mutate(an_mes=2026)
#   variables <- c("growingseasonprecipitation")
#   expect_error(extract_climat_an(file=liste_place, variable=variables))
# })
# test_that("La fonction extract_climat_an retourne une erreur an_mes-periode < 1970", {
#   liste_place <- fic_test %>% mutate(an_mes=1979)
#   periode=10
#   variables <- c("growingseasonprecipitation")
#   expect_error(extract_climat_an(file=liste_place, variable=variables, periode=periode))
# })
test_that("La fonction extract_climat_an retourne une erreur an_mes > 2023", {
  liste_place <- fic_test %>% mutate(an_mes=2024)
  variables <- c("growingseasonprecipitation")
  expect_error(extract_climat_an(file=liste_place, variable=variables),"an_mes ne doit pas être supérieure 2023")
})
test_that("La fonction extract_climat_an retourne une erreur an_mes-periode < 1980", {
  liste_place <- fic_test %>% mutate(an_mes=1985)
  periode=10
  variables <- c("growingseasonprecipitation")
  expect_error(extract_climat_an(file=liste_place, variable=variables, periode=periode),"an_mes-periode ne doit pas être inférieure à 1980")
})


test_that("La fonction extract_climat_an retourne le fichier attendu", {

  fic = fic_test[1,]
  variable = "growingseasontmean"
  periode=2
  value <- extract_climat_an(file=fic, variable=variable, periode=periode)
  # id_pe             latitude longitude an_mes
  # 0700200501_N_1970     47.9     -72.6   2007

  # an_mes de la placette 1: 2007, il faut donc tmean de 2005 et 2006

  # les valeurs attendues ont été extraites de QGIS, en glissant le fichier tif dans un projet et en mettant les 2 coordoonées dans un fichier excel (je l'ai mis sous data_raw)
  # on glisse ensuite le fichier excel sur la carte dans QGIS. On va dans la fenêtre de droite et on fait rechercher : on tape créer... et on choisit Créer une couche de points à partir d'une table
  # Dans la fenêtre qui apparait choisir les champs pour x et y et cliquer sur Exécuter
  # zoomer sur les points et sélectionner dans la barre d'outils le sigle i avec une flèche "identifer les entités".
  # la valeur du point apparait en bas à droit "Résultat de l'identification
  #valeur_attendu1 <- c(14.967177, 14.847577) # 2005
  #valeur_attendu2 <- c(14.701443, 14.126343) # 2006
  #valeur_attendu1 <- c(14.847577) # 2005
  #valeur_attendu2 <- c(14.126343) # 2006
  valeur_attendu1 <- c(14.8) # 2005, arrondi
  valeur_attendu2 <- c(14.1) # 2006, arrondi

   # faire la moyenne des annees
  moy_attendu <- round(mean(rbind(valeur_attendu1,valeur_attendu2)),2)
  valeur_obtenu <-  round(as.numeric(value[1,5]),2)

  expect_equal(valeur_obtenu,moy_attendu)

})


# test_that("La fonction extract_climat_an fonctionne si an_mes>2023", {
#
#   variable = "growingseasontmean"
#   periode=2
#   file = fic_test %>% mutate(an_mes=2025) # moyenne de 2023 et 2024, qui n'existent pas
#   # je m'attends à la moyenne des années 2021 et 2022
#
#
#   # aller chercher la valeur en 2021
#   periode=1
#   file = fic_test %>% mutate(an_mes=2022)
#   val_2021 <- extract_climat_an(file=file[1,], variable=variable, periode=periode)
#   # val_2021$growingseasontmean # 15.57975
#
#   # aller chercher la valeur en 2022
#   periode=1
#   file = fic_test %>% mutate(an_mes=2023)
#   val_2022 <- extract_climat_an(file=file[1,], variable=variable, periode=periode)
#   # val_2022$growingseasontmean # 15.21005
#
#   # moyenne de 2021 et 2022
#   moy_attendu <- (val_2021$growingseasontmean+val_2022$growingseasontmean)/2 # 15.3949
#
#
#   periode=2
#   file = fic_test %>% mutate(an_mes=2025)
#   valeur <- extract_climat_an(file=file[1,], variable=variable, periode=periode)
#   valeur_obtenu <- valeur$growingseasontmean # 15.3949
#
#   expect_equal(round(valeur_obtenu,4), round(moy_attendu,4))
#
# })
#
# test_that("La fonction extract_climat_an fonctionne si an_mes<1980", {
#
#   variable = "growingseasontmean"
#   periode=2
#   file = fic_test %>% mutate(an_mes=1975)
#   # je m'attends à la moyenne des années 1980 et 1981
#
#   # aller chercher la valeur en 1980
#   periode=1
#   file = fic_test %>% mutate(an_mes=1981)
#   val_1980 <- extract_climat_an(file=file[1,], variable=variable, periode=periode)
#   #val_1980$growingseasontmean # 12.89924
#
#   # aller chercher la valeur en 1981
#   periode=1
#   file = fic_test %>% mutate(an_mes=1982)
#   val_1981 <- extract_climat_an(file=file[1,], variable=variable, periode=periode)
#   #val_1981$growingseasontmean # 14.25239
#
#   # moyenne de 1980 et 1981
#   moy_attendu <- (val_1980$growingseasontmean+val_1981$growingseasontmean)/2 # 13.57582
#
#
#   periode=2
#   file = fic_test %>% mutate(an_mes=1975)
#   valeur <- extract_climat_an(file=file[1,], variable=variable, periode=periode)
#   valeur_obtenu <- valeur$growingseasontmean #
#
#   expect_equal(round(valeur_obtenu,4), round(moy_attendu,4))
# })
#
#
#
# test_that("La fonction extract_climat_an fonctionne si an_mes<1980 et an_mes>2023", {
#
#   variable = "growingseasontmean"
#   periode=2
#   file1 = fic_test %>% mutate(an_mes=1975) %>% filter(id_pe=="0700200501_N_1970") %>% mutate(id_pe='1')
#   file2 = fic_test %>% mutate(an_mes=2025) %>% filter(id_pe=="0700200501_N_1970") %>% mutate(id_pe='2')
#   file <- bind_rows(file1, file2)
#
#   moy_attendu_1975 <- 13.57582
#   moy_attendu_2025 <- 15.3949
#   moy_attendu <- c(moy_attendu_1975, moy_attendu_2025)
#
#
#   valeur <- extract_climat_an(file=file, variable=variable, periode=periode)
#   valeur_obtenu <- valeur$growingseasontmean # 13.57582 15.39490
#
#   expect_equal(round(valeur_obtenu,4), round(moy_attendu,4))
# })


# tester le chemin d'accès global




