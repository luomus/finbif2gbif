#' Check registration
#'
#' Check if a FinBIF collection is registered with GBIF.
#'
#' @param datasets List. GBIF dataset metadata retrieved using `gbif_datasets`.
#' @param collection_id Character. ID string of FinBIF collection.
#' @param quiet Logical. Suppress messages.
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
  collection_id,
  quiet = FALSE
) {

  ans <- vapply(datasets, has_identifier, logical(1L), collection_id)

  ans <- which(ans)

  if (length(ans) > 0L) {

    ans <- ans[[1L]]

    ans <- structure(
      ans,
      class = "registration",
      key = datasets[[ans]][["key"]],
      publisher_key = datasets[[ans]][["publishingOrganizationKey"]],
      created = datasets[[ans]][["created"]],
      last_mod = as.Date(datasets[[ans]][["modified"]])
    )

    if (!quiet) {

      message(
        sprintf(
          "INFO [%s] Dataset %s reg as %s by %s on %s and last mod %s",
          format(Sys.time()),
          collection_id,
          attr(ans, "key"),
          attr(ans, "publisher_key"),
          attr(ans, "created"),
          attr(ans, "last_mod")
        )
      )

    }

  } else {

    if (!quiet) {

      message(
        sprintf(
          "INFO [%s] Collection %s has not been registered",
          format(Sys.time()),
          collection_id
        )
      )

    }

    ans <- NULL

  }

  ans

}

has_identifier <- function(x, collection_id) {

  x <- vapply(x[["identifiers"]], getElement, character(1L), "identifier")

  x <- vapply(
    x,
    identical,
    logical(1L),
    sprintf("http://tun.fi/%s", as.character(collection_id))
  )

  any(x)

}
