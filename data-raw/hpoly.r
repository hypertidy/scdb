library(spbabel)
library(dplyr)
hpoly <- spbabel::sp(holey) %>% sf::st_as_sf()
hpoly$feature <- c("wall", "roof", "door")
devtools::use_data(hpoly, overwrite = TRUE)

library(scdb)
hfile <- "hpoly.sqlite"
## TODO I can't remove this file after rm(a) without restarting, is there a pointer hanging around?
a <- write_db(hpoly, dbfile = file.path("inst/extdata", hfile))
writeLines(c(hfile, "generated in data-raw/hpoly.r"), file.path("inst/extdata", "README"))
