#' Skip collection
#'
#' Should the collection be skipped?
#'
#' @param collection_id Character. Collection id.
#' @param enabled Logical.
#' @param collections Character. Path to collections.json file.
#'
#' @return Logical.
#' @examples \dontrun{
#'
#' skip_collection("HR.139")
#'
#' }
#' @importFrom jsonlite read_json
#' @export

skip_collection <- function(
  collection_id,
  enabled = config::get("enabled"),
  collections = "collections.json"
) {

  id <- as.character(collection_id)

  whitelist <- jsonlite::read_json(collections, simplifyVector = FALSE)

  whitelist <- vapply(whitelist, getElement, "", "id")

  in_wl <- id %in% whitelist

  ans <- !enabled || !in_wl || count_occurrences(list(collection = id)) < 1L

  if (ans) {

    message(
      sprintf(
        "INFO [%s] FinBIF collection %s will be skipped", format(Sys.time()), id
      )
    )

  } else {

    message(
      sprintf(
        "INFO [%s] FinBIF collection %s ready for archiving",
        format(Sys.time()),
        id
      )
    )

  }

  ans

}
