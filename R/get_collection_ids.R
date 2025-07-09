#' Get collection IDs
#'
#' Get collection IDs of FinBIF collections that are published to GBIF.
#'
#' @param datasets List. GBIF dataset metadata retrieved using `gbif_datasets`.
#' @param collection_ids Character. Collection ids to include regardless of
#'   sharing status.
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
  datasets,
  collection_ids = config::get("collections")
) {

  cols <- finbif::finbif_collections(
    select = TRUE, supercollections = TRUE, nmin = NA
  )

  which_to_gbif <- which(cols[["share_to_gbif"]] == cols[["id"]])

  if (is.null(collection_ids)) {

    collection_ids <- character()

  }

  which_to_gbif <- unique(
    c(which_to_gbif, which(cols[["id"]] %in% collection_ids))
  )

  to_gbif_cols <- cols[which_to_gbif, ]

  for (id in to_gbif_cols[["id"]]) {

    ids_remove <- id

    parents <- get_parents(id, cols)

    registered_parent <- FALSE

    for (pid in parents) {

      reg <- get_registration(datasets, pid, TRUE)

      registered_parent <- registered_parent || !is.null(reg)

    }

    if (!registered_parent) {

      ids_remove <- parents

    }

    ids_keep <- setdiff(to_gbif_cols[["id"]], ids_remove)

    to_gbif_cols <- to_gbif_cols[ids_keep, ]

  }

  ans <- as.list(to_gbif_cols[["id"]])

  for (i in seq_along(ans)) {

    last_mod <- as.Date(unlist(to_gbif_cols[["date_edited"]][[i]]))

    publisher <-
      config::get("publisher", ans[[i]]) %||%
      to_gbif_cols[["publisher_shortname"]][[i]]

    ans[[i]] <- structure(
      ans[[i]],
      class = "col_id",
      last_mod = sort(last_mod, TRUE, TRUE)[[1L]],
      publisher = publisher,
      gbif_org_id = attr(
        get_registration(datasets, ans[[i]], TRUE), "publisher_key"
      )
    )

  }

  message(
    sprintf(
      "INFO [%s] %s FinBIF collections set for publication",
      format(Sys.time()),
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
