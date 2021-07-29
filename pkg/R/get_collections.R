#' Get collection IDs
#'
#' Get collection IDs of FinBIF collections that are published to GBIF.
#'
#' @return A character vector.
#' @examples
#' get_datasets()
#' @importFrom finbif finbif_collections
#' @export

get_collection_ids <- function() {

  cols <- finbif::finbif_collections(supercollections = TRUE)

  cols[cols[["share_to_gbif"]], "id"]

  # TODO
  # For use when backend changes are implemened
  # cols[cols[["share_to_gbif"]] == cols[["id"]], "id"]

}
