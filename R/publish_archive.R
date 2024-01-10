#' Publish archive
#'
#' Publish a Darwin Core archive.
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

publish_archive <- function(
  staged_archive,
  dir = "archives"
) {

  system2("combine-dwca.sh", staged_archive)

  n_out <- system(
    sprintf("unzip -p %s -x meta.xml eml.xml | wc -l", staged_archive), TRUE
  )

  n_out <- as.integer(n_out) - 1L

  message(
    sprintf(
      "INFO [%s] Found %s records in archive, %s; file, occurrence.txt",
      format(Sys.time()),
      n_out,
      staged_archive
    )
  )

  combined_archive <- file.path(dir, "combined", basename(staged_archive))

  ans <- file.copy(staged_archive, combined_archive, overwrite = TRUE)

  message(
    sprintf(
      "INFO [%s] %s published to %s",
      format(Sys.time()),
      staged_archive,
      combined_archive
    )
  )

  ans

}
