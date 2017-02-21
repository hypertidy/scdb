## infix sugar for if (is.null)
"%||%" <- function(a, b) {
  if (is.null(a)) b else a
}