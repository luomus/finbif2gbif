#' Get archive file path
#'
#' Get the file path of an archive for a collection.
#'
#' @param staged_archive Character. Path to the staged archive.
#' @param dir Character. Path to the archive directory
#'
#' @return Character. The file path of the staged archive.
#' @examples \dontrun{
#'
#' publish_archive("stage/archive.zip")
#'
#' }
#' @export

publish_archive <- function(
  staged_archive,
  dir = "archive"
) {

  archive <- file.path(dir, basename(staged_archive))

  file.copy(staged_archive, archive, overwrite = TRUE)

  message(sprintf("[INFO] %s published to %s", staged_archive, archive))

  unlink(staged_archive)

}
