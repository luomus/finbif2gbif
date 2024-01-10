#' Skip GBIF update
#'
#' Should updating the collection for GBIF be skipped?
#'
#' @param collection_id Character. Collection id.
#' @param enabled Logical.
#'
#' @return Logical.
#' @examples \dontrun{
#'
#' skip_gbif("HR.139")
#'
#' }
#' @export

skip_gbif<- function(
  collection_id,
  enabled = config::get("gbif")
) {

  id <- as.character(collection_id)

  ans <- !enabled

  if (ans) {

    message(
      sprintf(
        "INFO [%s] GBIF sync for %s will be skipped", format(Sys.time()), id
      )
    )

  } else {

    message(
      sprintf(
        "INFO [%s] FinBIF collection %s ready for GBIF sync",
        format(Sys.time()),
        id
      )
    )

  }

  ans

}
