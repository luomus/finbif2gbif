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

get_collection_ids <- function() {

  cols <- finbif::finbif_collections(
    select = TRUE, supercollections = TRUE, nmin = NA
  )

  # Share to gbif column can contain missing data
  cols[which(cols[["share_to_gbif"]]), "id"]

  # TODO
  # For use when backend changes are implemented
  # cols[which(cols[["share_to_gbif"]] == cols[["id"]]), "id"]

}
