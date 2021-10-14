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

get_registration <- function(
  datasets,
  collection_id
) {

  ans <- vapply(datasets, has_identifier, logical(1L), collection_id)

  ans <- which(ans)[[1L]]

  if (length(ans) > 0L) {

    ans <- structure(
      ans,
      class = "registration",
      key = datasets[[ans]][["key"]],
      created = datasets[[ans]][["created"]],
      last_mod = as.Date(datasets[[ans]][["modified"]])
    )

    message(
      sprintf(
        "[INFO] Collection %s registered as %s on %s and last modified on %s",
        collection_id,
        attr(ans, "key"),
        attr(ans, "created"),
        attr(ans, "last_mod")
      )
    )

  } else {

    message(
      sprintf("[INFO] Collection %s has not been registered", collection_id)
    )

    ans <- NULL

  }

  ans

}

has_identifier <- function(x, collection_id) {

  x <- vapply(x[["identifiers"]], getElement, character(1L), "identifier")

  x <- vapply(x, identical, logical(1L), as.character(collection_id))

  any(x)

}
