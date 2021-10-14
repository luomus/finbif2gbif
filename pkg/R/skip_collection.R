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

  zero_records <- count_occurrences(list(collection = collection_id)) < 1L

  ans <- !enabled || zero_records

  if (ans) {

    message(
      sprintf("[INFO] FinBIF collection %s will be skipped", collection_id)
    )

  } else {

    message(
      sprintf("[INFO] FinBIF collection %s ready for archiving", collection_id)
    )

  }

  ans

}
