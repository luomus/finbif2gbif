#' Get occurrence file name.
#'
#' Get the file name of occurrences in an archive
#'
#' @param filter List.
#' @param prefix Character.
#' @param subsets List.
#'
#' @return Character. The file name holding occurrence records.
#' @examples \dontrun{
#'
#' get_occurrence_file(list())
#'
#' }
#' @importFrom digest digest
#' @export

get_occurrence_file <- function(
  filter,
  prefix = "occurrence",
  subsets = config::get("subsets")
) {

  suffix <- ""

  if (length(subsets) > 1L) {

    suffix <- paste0("_", digest::digest(filter, "xxhash32"))

  }

  paste0(prefix, suffix, ".txt")

}
