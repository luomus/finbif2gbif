#' Get collection IDs
#'
#' Get collection IDs of FinBIF collections that are published to GBIF.
#'
#' @return A character vector.
#' @examples \dontrun{
#'
#' get_collection_ids()
#'
#' }
#' @importFrom finbif finbif_collections
#' @export

get_collection_ids <- function(
) {

  cols <- finbif::finbif_collections(
    select = TRUE, supercollections = TRUE, nmin = NA
  )

  which_to_gbif <- which(cols[["share_to_gbif"]] == cols[["id"]])

  if (inherits(cols[["share_to_gbif"]], "logical")) {

    which_to_gbif <- which(cols[["share_to_gbif"]])

  }

  to_gbif_cols <- cols[which_to_gbif, ]

  to_gbif_ids <- to_gbif_cols[["id"]]

  for (id in to_gbif_ids) {

    parents <- get_parents(id, cols)

    ids_keep <- setdiff(to_gbif_cols[["id"]], parents)

    to_gbif_cols <- to_gbif_cols[ids_keep, ]

  }

  ans <- as.list(to_gbif_cols[["id"]])

  for (i in seq_along(ans)) {

    ans[[i]] <- structure(
      ans[[i]], class = "col_id",
      last_mod = as.Date(to_gbif_cols[i, "date_edited"])
    )

  }

  message(
    sprintf(
      "INFO [%s] %s FinBIF collections set for publication",
      Sys.time(),
      length(ans)
    )
  )

  ans

}

#' @noRd

get_parents <- function(x, cols) {

  setdiff(add_parents(x[[1L]], cols), x[[1L]])

}

#' @noRd

add_parents <- function(x, cols) {

  x <- sort(unique(x))

  parents <- cols[x, "is_part_of"]

  y <- sort(unique(c(parents[!is.na(parents)], x)))

  if (identical(x, y)) {

    x

  } else {

    add_parents(y, cols)

  }

}
