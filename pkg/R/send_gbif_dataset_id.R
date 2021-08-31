#' GBIF dataset identifier
#'
#' Send FinBIF dataset identifier to GBIF.
#'
#' @param id Character. FinBIF collection ID for dataset.
#' @param uuid Character. GBIF dataset identifier. Returned by
#'   `send_gbif_dataset_metadata`.
#' @param url Character. URL of GBIF API. Defaults to system environment
#'   variable, "GBIF_API".
#' @param user Character. GBIF username. Defaults to system environment
#'   variable, "GBIF_USER".
#' @param pass Character. GBIF password. Defaults to system environment
#'   variable, "GBIF_PASS".
#'
#' @return If successful returns `NULL` invisibly.
#' @examples \dontrun{
#'
#' m <- get_metadata("HR.3991")
#' uuid <- send_gbif_dataset_metadata(m)
#' send_gbif_dataset_id("HR.3991", uuid)
#'
#' }
#' @importFrom httr authenticate RETRY status_code
#' @export

send_gbif_dataset_id <- function(
  id,
  uuid,
  url = Sys.getenv("GBIF_API"),
  user = Sys.getenv("GBIF_USER"),
  pass = Sys.getenv("GBIF_PASS")
) {

  auth <- httr::authenticate(user, pass)

  res <- httr::RETRY(
    "POST",
    url = url,
    config = auth,
    path = sprintf("v1/dataset/%s/identifier", uuid),
    body = list(type = "UNKNOWN", identifier = id),
    encode = "json"
  )

  status <- httr::status_code(res)

  ok <- identical(status, 201L)

  stopifnot("Post failed. Could not send identifier to GBIF" = ok)

  invisible(NULL)

}
