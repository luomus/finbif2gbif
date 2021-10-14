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

  archive_path <- sprintf("%s/%s.zip", dir, collection_id)

  message(
    sprintf(
      "[INFO] Collection %s will be published to %s",
      collection_id,
      archive_path
    )
  )

  structure(archive_path, class = "archive_file")

}
