#' Get collection IDs
#'
#' Get collection IDs of FinBIF collections that are published to GBIF.
#'
#' @return A character vector.
#' @examples
#' get_collection_ids()
#' @importFrom finbif finbif_collections
#' @export

get_collection_ids <- function() {

  cols <- finbif::finbif_collection(
    select = TRUE, supercollections = TRUE, nmin = NA
  )

  cols[cols[["share_to_gbif"]], "id"]

  # TODO
  # For use when backend changes are implemented
  # cols[cols[["share_to_gbif"]] == cols[["id"]], "id"]

}
