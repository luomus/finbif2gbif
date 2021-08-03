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
#' gbif_datasets()
#'
#' }
#' @importFrom httr content RETRY status_code
#' @importFrom jsonlite fromJSON
#' @export

gbif_datasets <- function(
  url = Sys.getenv("GBIF_API"),
  installation = Sys.getenv("GBIF_INSTALLATION")
) {

  res <- httr::RETRY(
    "GET",
    url = url,
    path = sprintf("v1/installation/%s/dataset", installation),
    query = list(limit = 1L)
  )

  status <- httr::status_code(res)

  stopifnot(
    "Request failed. Could not get number of datasets available from GBIF" =
      identical(status, 200L)
  )

  n <- httr::content(res, "text", encoding = "UTF-8")
  n <- jsonlite::fromJSON(n, simplifyVector = FALSE)

  res <- httr::RETRY(
    "GET",
    url = url,
    path = sprintf("v1/installation/%s/dataset", installation),
    query = list(limit = n[["count"]])
  )

  status <- httr::status_code(res)

  stopifnot(
    "Request failed. Could not get dataset metadata from GBIF" =
      identical(status, 200L)
  )

  datasets <- httr::content(res, "text", encoding = "UTF-8")
  datasets <- jsonlite::fromJSON(datasets, simplifyVector = FALSE)

  datasets[["results"]]

}
