#' Skip collection
#'
#' Should the collection be skipped?
#'
#' @param skip Logical.
#' @param collection_id Character. Collection id.
#'
#' @return Logical.
#' @examples \dontrun{
#'
#' skip_collection()
#'
#' }
#' @export

skip_collection <- function(
  enabled = config::get("enabled"),
  collection_id
) {

  zero_records <- count_occurrences(list(collection = collection_id)) < 1L

  !enabled || zero_records

}
