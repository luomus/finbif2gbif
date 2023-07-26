#' Get occurrence file name.
#'
#' Get the file name of occurrences in an archive
#'
#' @param filter List.
#' @param select Character.
#' @param prefix Character.
#'
#' @return Character. The file name holding occurrence records.
#' @examples \dontrun{
#'
#' get_file_name(list())
#'
#' }
#' @importFrom digest digest
#' @export

get_file_name <- function(
  filter,
  select = config::get("fields"),
  prefix = "occurrence"
) {

  suffix <- paste0("_", digest::digest(list(filter, select), "xxhash32"))

  paste0(prefix, suffix, ".txt")

}
