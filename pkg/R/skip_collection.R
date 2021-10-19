#' Skip collection
#'
#' Should the collection be skipped?
#'
#' @param collection_id Character. Collection id.
#' @param enabled Logical.
#'
#' @return Logical.
#' @examples \dontrun{
#'
#' skip_collection()
#'
#' }
#' @export

skip_collection <- function(
  collection_id,
  enabled = config::get("enabled")
) {

  id <- as.character(collection_id)

  zero_records <- count_occurrences(list(collection = as.character(id))) < 1L

  ans <- !enabled || zero_records

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
