#' Get UUID
#'
#' Get the UUID of a registered dataset.
#'
#' @param registration Integer.
#'
#' @return Character.
#' @examples \dontrun{
#'
#' registration <- get_registration(gbif_datasets(), "HR.3991")
#' get_uuid(registration)
#'
#' }
#' @export

get_uuid <- function(
  registration
) {

  attr(registration, "key")

}
