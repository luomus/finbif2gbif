#' Get subsets
#'
#' Get subset filters for a collection.
#'
#' @param collection_id Character. ID string of FinBIF collection.
#' @param filter List.
#' @param nmax Integer. Maximum allowed size of subset.
#'
#' @return A list.
#' @examples \dontrun{
#'
#' get_subsets("HR.3991")
#'
#' }
#' @export

get_subsets <- function(
  collection_id,
  filters = config::get("filters"),
  nmax = config::get("nmax")
) {

  filters <- c(collection = collection_id, filters)

  n <- finbif::finbif_occurrence(filter = filters, select = "record_id", n = 1L)

  n <- attr(n, "nrec_avl")

  message(
    sprintf(
      "INFO [%s] Found %s occurrence records in FinBIF for filter: %s",
      Sys.time(),
      n,
      paste(trimws(capture.output(dput(as.list(filters)))), collapse = " ")
    )
  )

  n_subsets <- n %/% as.integer(nmax) + 1

  subsets <- list()

  txt <- "subsets"

  for (subset in seq_len(n_subsets)) {

    partition <- list(subset = c(subset, n_subsets))

    if (identical(n_subsets, 1)) {

      partition <- NULL
      txt <- "subset"

    }

    subsets[[subset]] <- c(filters, partition)

  }

  message(
    sprintf(
      "INFO [%s] Collection %s to be partitioned into %s %s",
      Sys.time(),
      collection_id,
      n_subsets,
      txt
    )
  )

  subsets

}
