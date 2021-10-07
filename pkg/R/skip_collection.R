#' Skip collection
#'
#' Should the collection be skipped?
#'
#' @param skip Logical.
#'
#' @return Logical.
#' @examples \dontrun{
#'
#' skip_collection()
#'
#' }
#' @export

skip_collection <- function(
  skip = !config::get("enabled")
) {

  skip

}
