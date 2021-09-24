#' Check registration
#'
#' Check if a FinBIF collection is registered with GBIF.
#'
#' @param datasets List. GBIF dataset metadata retrieved using `gbif_datasets`.
#' @param collection_id Character. ID string of FinBIF collection.
#'
#' @return Integer.
#' @examples \dontrun{
#'
#' get_registration(gbif_datasets(), "HR.3991")
#'
#' }
#' @export

get_registration <- function(datasets, collection_id) {

  ans <- vapply(datasets, has_identifier, logical(1L), collection_id)

  ans <- which(ans)

  if (length(ans) > 0L) {

    attr(ans, "key") <- datasets[[ans]][["key"]]
    attr(ans, "created") <- datasets[[ans]][["created"]]
    attr(ans, "last_mod") <- as.Date(datasets[[ans]][["modified"]])


  } else {

    ans <- FALSE

  }

  ans

}

has_identifier <- function(x, collection_id) {

  x <- vapply(x[["identifiers"]], getElement, character(1L), "identifier")

  x <- vapply(x, identical, logical(1L), collection_id)

  any(x)

}
