#' Unstage archive
#'
#' Unstage an updated archive file.
#'
#' @param staged_archive Character. Path to the staged archive.
#' @param dir Character. Path to the archive directory.

#'
#' @return Character. The file path of the staged archive.
#' @examples \dontrun{
#'
#' publish_archive("stage/archive.zip")
#'
#' }
#' @export

unstage_archive <- function(
  staged_archive,
  dir = "archives"
) {

  split_archive <- file.path(dir, "split", basename(staged_archive))

  class(split_archive) <- "archive_file"

  file.copy(staged_archive, split_archive, overwrite = TRUE)

}
