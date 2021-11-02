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
  dir = "archives"
) {

  split_archive <- file.path(dir, "split", basename(staged_archive))

  combined_archive <- file.path(dir, "combined", basename(staged_archive))

  file.copy(staged_archive, split_archive, overwrite = TRUE)

  system2("combine-dwca.sh", split_archive)

  file.copy(split_archive, combined_archive, overwrite = TRUE)

  file.copy(staged_archive, split_archive, overwrite = TRUE)

  message(
    sprintf(
      "INFO [%s] %s published to %s", Sys.time(), staged_archive,
      combined_archive
    )
  )

  unlink(staged_archive)

}
