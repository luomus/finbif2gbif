#' Check registration
#'
#' Check if a FinBIF collection is registered with GBIF.
#'
#' @param datasets List. GBIF dataset metadata retrieved using `gbif_datasets`.
#' @param collection_id Character. ID string of FinBIF collection.
#'
#' @return A character vector.
#' @examples \dontrun{
#'
#' is_registered(gbif_datasets(), "HR.3991")
#'
#' }
#' @export

is_registered <- function(datasets, collection_id) {

  ans <- vapply(datasets, has_identifier, logical(1L), collection_id)

  any(ans)

}

has_identifier <- function(x, collection_ids) {

  x <- vapply(x[["identifiers"]], getElement, character(1L), "identifier")

  x <- vapply(x, identical, logical(1L), id)

  any(x)

}
