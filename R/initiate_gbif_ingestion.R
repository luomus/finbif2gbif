#' Initiate ingestion
#'
#' Ingitiate GBIF ingestion of FinBIF data.
#'
#' @param uuid Integer. GBIF registration id.
#' @param url Character. URL of GBIF API. Defaults to system environment
#'   variable, "GBIF_API".
#' @param user Character. GBIF username. Defaults to system environment
#'   variable, "GBIF_USER".
#' @param pass Character. GBIF password. Defaults to system environment
#'   variable, "GBIF_PASS".
#' @return NULL.
#' @examples \dontrun{
#'
#' collection <- get_collection_ids()[[1L]]
#' registration <- get_registration(get_gbif_datasets(), collection)
#' initiate_gbif_ingestion(registration)
#'
#' }
#' @importFrom httr authenticate RETRY status_code
#' @export

initiate_gbif_ingestion <- function(
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
    path = sprintf("v1/dataset/%s/crawl", uuid)
  )

  status <- httr::status_code(res)

  ok <- identical(status, 204L)

  stopifnot("Inititate crawl failed" = ok)

  message(
    sprintf(
      "INFO [%s] GBIF ingestion intitiated for dataset: %s",
      format(Sys.time()),
      uuid
    )
  )

  invisible(NULL)

}
