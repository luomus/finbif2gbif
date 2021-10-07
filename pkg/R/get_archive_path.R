#' Get archive file path
#'
#' Get the file path of an archive for a collection.
#'
#' @param collection_id Character. Collection id.
#' @param dir Character. Path to the archive directory.
#'
#' @return Character. The file path of the archive.
#' @examples \dontrun{
#'
#' get_archive_path("HR.3991")
#'
#' }
#' @export

get_archive_path <- function(
  collection_id,
  dir = "archives"
) {

  structure(sprintf("%s/%s.zip", dir, collection_id), class = "archive_file")

}
