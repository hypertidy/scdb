library(spbabel)
library(dplyr)
hpoly <- spbabel::sp(holey) %>% sf::st_as_sf()
hpoly$feature <- c("wall", "roof", "door")
devtools::use_data(hpoly, overwrite = TRUE)