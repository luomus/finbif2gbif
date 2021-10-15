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

  id <- as.character(id)

  zero_records <- count_occurrences(list(collection = as.character(id))) < 1L

  ans <- !enabled || zero_records

  if (ans) {

    message(
      sprintf("[INFO] FinBIF collection %s will be skipped", id)
    )

  } else {

    message(
      sprintf("[INFO] FinBIF collection %s ready for archiving", id)
    )

  }

  ans

}
