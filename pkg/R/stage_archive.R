#' Get archive file path
#'
#' Get the file path of an archive for a collection.
#'
#' @param archive Character. Path to the archive.
#' @param stage Character. Path to the staging directory.
#'
#' @return Character. The file path of the staged archive.
#' @examples \dontrun{
#'
#' stage_archive("archive.zip")
#'
#' }
#' @export

stage_archive <- function(
  archive,
  stage = "stage"
) {

  staged_archive <- file.path(stage, basename(archive))

  if (file.exists(archive)) {

    file.copy(archive, staged_archive, overwrite = TRUE)

  }

  structure(staged_archive, class = "archive_file")

}
