test_that("La fonction extract_climat_an retourne le fichier attendu", {

  carte = cartes_climat_an
  couche = 1
  variable = "growingseasontmean"
  periode=2
  value <- extract_climat_an(file=fic_test, liste_raster=carte, variable=variable, couche=couche, periode=periode)


  nom_attendu <-  c(names(fic_test), variable)
  expect_equal(names(value),nom_attendu)

  # valeur attendu = moyenne de 2005 à 2006 pour la ligne 1
  liste_place <- fic_test %>% dplyr::select(id_pe, latitude, longitude, an_mes) %>%  unique()
  an_min <- min(liste_place$an_mes)-periode
  an_max <- max(liste_place$an_mes)-1
  variable_tous <- NULL
  for (i in an_min:an_max){
    for (j in 1:length(variable)){
      var_ij <- paste0(variable[j],i)
      variable_tous <- c(variable_tous, var_ij)
    }
  }
  clim_an <- extract_carte(liste_place=liste_place, carte=carte, variable=variable_tous, couche=1)
  # faire la moyenne des bonnes années
  moy_obtenu <- rbind(value[1,5], value[2,5])
  expect_equal(as.numeric(value[1,5]),moy_attendu[1])

})


test_that("La fonction extract_climat_an retourne une erreur si an_mes>2023", {

  carte = cartes_climat_an
  couche = 1
  variable = "growingseasontmean"
  periode=2
  file = fic_test %>% mutate(an_mes=2024)

  expect_error(extract_climat_an(file=file, liste_raster=carte, variable=variable, couche=couche, periode=periode))

})

test_that("La fonction extract_climat_an retourne une erreur si an_mes-periode<1980", {

  carte = cartes_climat_an
  couche = 1
  variable = "growingseasontmean"
  periode=30

  expect_error(extract_climat_an(file=fic_test, liste_raster=carte, variable=variable, couche=couche, periode=periode))

})
