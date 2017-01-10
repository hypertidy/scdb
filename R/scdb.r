#' Build database from object.
#'
#' Currently only objects supported by `spbabel::map_table` are supported ....
#' @param x object
#' @param dbfile SQLite file name
#' @param layer object layer name (defaults to the name of `x`)
#' @param verbose chatty mode
#' @return db object
#' @export
#'
#' @examples
#' write_db(hpoly)
#' @importFrom spbabel map_table
#' @importFrom dplyr copy_to src_sqlite
#' @importFrom progress progress_bar
write_db <- function(x,  dbfile, layer = NULL, slurp = FALSE, verbose = TRUE) {
  layer <- layer %||%  deparse(substitute(x))
  dbfile <- dbfile %||%  sprintf("%s.sqlite", tempfile())
  db <- dplyr::src_sqlite(dbfile, create = TRUE)

  ## decompose to tables
  if (verbose) message("decomposing object")
  ## TODO use new simple features model
  tabs <- spbabel::map_table(x)
  pb <- progress_bar$new(total = length(tabs))
  if (verbose) message(sprintf("write tables to database %s", dbfile))
  for (i in seq_along(tabs)) {
    dplyr::copy_to(db, tabs[[i]], name = names(tabs)[i], temporary = FALSE)
    if (verbose) pb$tick()
  }
  db
}


"%||%" <- function(a, b) {
  if (is.null(a)) b else a
}
