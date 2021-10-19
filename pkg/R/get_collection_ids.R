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

  # Share to gbif column can contain missing data
  cols <- cols[which(cols[["share_to_gbif"]]), c("id", "date_edited")]

  # TODO
  # For use when backend changes are implemented
  # cols[which(cols[["share_to_gbif"]] == cols[["id"]]), "id"]

  ans <- as.list(cols[["id"]])

  for (i in seq_along(ans)) {

    ans[[i]] <- structure(
      ans[[i]], class = "col_id", last_mod = as.Date(cols[i, "date_edited"])
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
