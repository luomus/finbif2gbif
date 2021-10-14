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

  n <- count_occurrences(filters)

  n_subsets <- pmax(n %/% as.integer(nmax), 1L)

  subsets <- list()

  txt <- "subsets"

  for (subset in seq_len(n_subsets)) {

    partition <- list(partition = c(subset, n_subsets))

    if (identical(n_subsets, 1L)) {

      partition <- NULL
      txt <- "subset"

    }

    subsets[[subset]] <- c(filters, partition)

  }

  message(
    sprintf(
      "[INFO] Collection %s to be partitioned into %s %s",
      collection_id,
      n_subsets,
      txt
    )
  )

  subsets

}
