test_that("La fonction extract_map_plot retourne le fichier attendu", {

  carte = cartes_sol
  couche = 2
  variable = c("cec","ph")
  value <- extract_map_plot(file=fic_test, liste_raster=carte, variable=variable, couche=couche)

  nom_couche <- tolower(names(carte[[1]])[[couche]])
  nom_var <- c(paste(variable[1], nom_couche, sep='.'), paste(variable[2], nom_couche, sep='.'))
  nom_attendu <-  c(names(fic_test), nom_var)
  expect_equal(names(value),nom_attendu)

  expect_equal(nrow(value),nrow(fic_test))



})
