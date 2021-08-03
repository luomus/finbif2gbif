#' GBIF datasets
#'
#' Get metadata for GBIF registered datasets of a given installation.
#'
#' @param url Character. URL of GBIF API. Defaults to system environment
#'   variable, "GBIF_API".
#' @param installation Character. ID key of GBIF installation. Defaults to
#'   system environment variable, "GBIF_INSTALLATION".
#'
#' @return A list.
#' @examples \dontrun{
#'
#' m <- get_metadata("HR.3991")
#' send_gbif_dataset_metadata(m)
#'
#' }
#' @importFrom httr authenticate content RETRY status_code
#' @importFrom jsonlite fromJSON
#' @export

send_gbif_dataset_metadata <- function(
  metadata,
  url = Sys.getenv("GBIF_API"),
  user = Sys.getenv("GBIF_USER"),
  pass = Sys.getenv("GBIF_PASS")
) {

  auth <- httr::authenticate(user, pass)

  res <- httr::RETRY(
    "POST",
    url = url,
    config = auth,
    path = "v1/dataset",
    body = metadata,
    encode = "json"
  )

  status <- httr::status_code(res)

  ok <- identical(status, 200L)

  stopifnot("Post failed. Could not send metadata to GBIF" = ok)

  uuid <- httr::content(res, "text", encoding = "UTF-8")

  jsonlite::fromJSON(uuid, simplifyVector = FALSE)

}
