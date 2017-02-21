#' Build database from object.
#'
#' Objects are converted to 'sc::PATH' common form. 
#' 
#' @param x object
#' @param src database
#' @param ... passed to methods
#' @param verbose defaults to `FALSE`
#'
#' @return db object
#' @export
#'
#' @examples
#' ## hpoly is an in-built simple features multipolygon layer
#' library(scsf)
#' db <- write_db(hpoly)
#' db
#' @importFrom dplyr copy_to src_sqlite
#' @importFrom sc PATH
write_db <- function(x, src = NULL,  ..., verbose = FALSE) {
  UseMethod("write_db")
}

#' @name write_db
#' @export
write_db.sf <- function(x, src = NULL,  ..., verbose = FALSE) {
  write_db(sc::PATH(x), src = src, ..., verbose = verbose)
}
#' @name write_db
#' @export
write_db.sc <- function(x, src = NULL,  ..., verbose = FALSE) {
  if (!inherits(x, "PATH") & !inherits(x, "PRIMITIVE")) {
    if (verbose) message("converting 'x' to a PATH")
    x <- PATH(x)
  }
  layers <- names(x)
  if (is.null(src)) {
    dbfile <- sprintf("%s.sqlite", tempfile())
    message(sprintf("creating temp database %s", dbfile))
    src <- dplyr::src_sqlite(dbfile, create = TRUE)
    
  } else { 
    if (!inherits(src, "src")) warning("'src' is not a src ...")  
  }
  for (i in seq_along(layers)) write_db(x[[layers[i]]], src, layers[i], ...)
  src
}
# @name write_db
write_db.data.frame <- function(x, src = NULL, name, ..., verbose = FALSE) {
  dplyr::copy_to(src, x, name = name, temporary = FALSE)
}
# @importFrom progress progress_bar
# @importFrom spbabel map_table
# old_write_db <- function(x,  dbfile = NULL, layer = NULL,  verbose = TRUE) {
#   layer <- layer %||%  deparse(substitute(x))
#   dbfile <- dbfile %||%  sprintf("%s.sqlite", tempfile())
#   db <- dplyr::src_sqlite(dbfile, create = TRUE)
#   
#   ## decompose to tables
#   if (verbose) message("decomposing object")
#   
#   ## hack
#   ## TODO use new simple features model
#   tabs <- spbabel::map_table(x)
#   
#   ## hack
#   ## remap names, probably just pull map_table/feature_table from spbabel to sc and standardize
#   ## or use classing to avoid the names completely
#   names(tabs) <- c(o = "object", b = "branch", bXv = "branch_vertex", v = "vertex")
#   
#   ## hack
#   ## eek not currently droppping the geometry column
#   nr <- unlist(lapply(tabs$o, is.atomic))
#   tabs$object[[names(nr)[!nr]]] <- NULL
#   
#   pb <- progress::progress_bar$new(total = length(tabs))
#   if (verbose) message(sprintf("write tables to database %s", dbfile))
#   for (i in seq_along(tabs)) {
#     dplyr::copy_to(db, tabs[[i]], name = names(tabs)[i], temporary = FALSE)
#     if (verbose) pb$tick()
#   }
#   db
# }