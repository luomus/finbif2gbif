#' Get occurrence file name.
#'
#' Get the file name of occurrences in an archive
#'
#' @param filter List.
#' @param select Character.
#' @param prefix Character.
#' @param collections Character. Path to collections.json file.
#'
#' @return Character. The file name holding occurrence records.
#' @examples \dontrun{
#'
#' get_file_name(list())
#'
#' }
#' @importFrom digest digest
#' @importFrom jsonlite read_json
#' @export

get_file_name <- function(
  filter,
  select = config::get("fields"),
  prefix = "occurrence",
  collections = "collections.json"
) {

  collection_id <- filter[["collection"]]

  collections <- jsonlite::read_json(collections, simplifyVector = FALSE)

  collection_ids <- vapply(collections, getElement, "", "id")

  collection <- collections[[which(collection_ids == collection_id)]]

  select <- setdiff(select, collection[["field_blacklist"]])

  filter$first_import_date_max <- NULL

  filter$include_null_import_dates <- NULL

  suffix <- paste0("_", digest::digest(list(filter, select), "xxhash32"))

  paste0(prefix, suffix, ".txt")

}
