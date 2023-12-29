#' Skip collection
#'
#' Should the collection be skipped?
#'
#' @param collection_id Character. Collection id.
#' @param enabled Logical.
#' @param whitelist Character. Path to white-list file.
#'
#' @return Logical.
#' @examples \dontrun{
#'
#' skip_collection("HR.139")
#'
#' }
#' @export

skip_collection <- function(
  collection_id,
  enabled = config::get("enabled"),
  whitelist = "whitelist.txt"
) {

  id <- as.character(collection_id)

  whitelist <- readLines(whitelist)

  in_wl <- id %in% whitelist

  ans <- !enabled || !in_wl || count_occurrences(list(collection = id)) < 1L

  if (ans) {

    message(
      sprintf("INFO [%s] FinBIF collection %s will be skipped", Sys.time(), id)
    )

  } else {

    message(
      sprintf(
        "INFO [%s] FinBIF collection %s ready for archiving",
        Sys.time(),
        id
      )
    )

  }

  ans

}
