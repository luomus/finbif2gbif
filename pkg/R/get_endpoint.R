#' Get endpoint
#'
#' Get FinBIF collection data endpoint needed for GBIF registration.
#'
#' @param collection_id Character. ID string of FinBIF collection.
#' @param url_base Character. The base URL for the collection's data endpoint.
#'   Defaults to system environment variable, "ENDPOINTS".
#'
#' @return A list.
#' @examples \dontrun{
#'
#' get_endpoint("HR.3991")
#'
#' }
#' @export

get_endpoint <- function(
  collection_id,
  url_base = Sys.getenv("ENDPOINTS")
) {

  ans <- list(
    list(
      type = "DWC_ARCHIVE",
      url = sprintf("%s/archives/%s.zip", url_base, collection_id)
    ),
    list(
      type = "EML",
      url = sprintf("%s/eml/%s.zip", url_base, collection_id)
    )
  )

  message(
    sprintf(
      "INFO [%s] Collection %s archive has endpoints %s and %s",
      Sys.time(),
      collection_id,
      ans[[1L]][["url"]],
      ans[[2L]][["url"]]
    )
  )

  ans

}
