#' Get endpoint
#'
#' Get FinBIF collection data endpoint needed for GBIF registration.
#'
#' @param collection_id Character. ID string of FinBIF collection.
#' @param url_base Character. The base URL for the collection's data endpoint.
#'   Defaults to system environment variable, "ENDPOINTS_URL_BASE".
#'
#' @return A list.
#' @examples
#' get_endpoint("HR.3991")
#'
#' @export

get_endpoint <- function(
  collection_id,
  url_base = Sys.getenv("ENDPOINTS")
) {

  list(
    type = "DWC_ARCHIVE",
    url = sprintf("%s/%s.zip", url_base, collection_id)
  )

}
