#' Get subsets
#'
#' Get subset filters for a collection.
#'
#' @param collection_id Character. ID string of FinBIF collection.
#' @param filters List.
#' @param nmax Integer. Maximum allowed size of subset.
#' @param facts List.
#' @param combine List.
#'
#' @return A list.
#' @examples \dontrun{
#'
#' get_subsets("HR.3991")
#'
#' }
#' @importFrom utils capture.output
#' @export

get_subsets <- function(
  collection_id,
  filters = config::get("filters"),
  nmax = config::get("nmax"),
  facts = config::get("facts"),
  combine = config::get("combine")
) {

  filters <- c(collection = collection_id, filters)

  n <- finbif::finbif_occurrence(
    filter = filters, select = "record_id", order_by = "record_id", n = 1L
  )

  n <- attr(n, "nrec_avl")

  message(
    sprintf(
      "INFO [%s] Found %s occurrence records in FinBIF for filter: %s",
      format(Sys.time()),
      n,
      paste(
        trimws(utils::capture.output(dput(as.list(filters)))), collapse = " "
      )
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

    attr(subsets[[subset]], "facts") <- facts

    attr(subsets[[subset]], "combine") <- combine

  }

  message(
    sprintf(
      "INFO [%s] Collection %s to be partitioned into %s %s",
      format(Sys.time()),
      collection_id,
      n_subsets,
      txt
    )
  )

  attr(subsets, "n") <- n

  attr(subsets, "collection_id") <- collection_id

  subsets

}
