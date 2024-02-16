test_that("La fonction extract_carte retourne les bons noms de colonnes et valeurs pour les sols", {

  carte = cartes_sol
  couche = 1
  variable = c("cec","silt")
  value <- extract_carte(liste_place=fic_test, carte=carte, variable=variable, couche=couche)

  nom_couche <- tolower(names(carte[[1]])[[couche]])
  nom_attendu <- c(paste(variable[1], nom_couche, sep='.'), paste(variable[2], nom_couche, sep='.'))

  expect_equal(names(value), nom_attendu)

  valeur_attendu <- rbind(1.814182, 1.148471)
  valeur_obtenu <- round(rbind(value[1,1], value[2,1]),6)
  expect_equal(valeur_obtenu, valeur_attendu)
})




test_that("La fonction extract_carte retourne les bons noms de colonnes pour les iqs", {

  carte = cartes_iqs
  couche = 1
  variable = c("iqs_pot_bop","iqs_pot_epn")
  value <- extract_carte(liste_place=fic_test, carte=carte, variable=variable, couche=couche)

  expect_equal(names(value), variable)

  valeur_attendu <- round(rbind(15.466656, 15.504798),5)
  valeur_obtenu <- round(rbind(value[1,1], value[2,1]),5)
  expect_equal(valeur_obtenu, valeur_attendu)

})

test_that("La fonction extract_carte retourne les bons noms de colonnes pour les climat normal 30 ans", {

  carte = cartes_climat
  couche = 1
  variable = c("tmean","totalprecipitation")
  value <- extract_carte(liste_place=fic_test, carte=carte, variable=variable, couche=couche)

  expect_equal(names(value), variable)

  valeur_attendu <- rbind(2.49900, 2.12072)
  valeur_obtenu <- round(rbind(value1[1,1], value1[2,1]),5)
  expect_equal(valeur_obtenu, valeur_attendu)

})



