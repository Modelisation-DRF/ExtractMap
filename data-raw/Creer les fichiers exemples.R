

# fichier test
file_compile="U:\\Projets\\IsabelleAuger\\Natura-2020\\PET\\PEP_MES1_compile.csv"
fichier_compile_complet <- read_delim(file=file_compile, delim = ';')
fic_test <- fichier_compile_complet %>% filter(id_pe %in% c('0700200501_N_1970', '1419610501_N_1922')) %>% dplyr::select(id_pe, latitude, longitude, an_mes)

# sauvegarder le fichier en rda sous /data
usethis::use_data(fic_test, overwrite = TRUE)
