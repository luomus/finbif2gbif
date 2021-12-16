#' Publish archive
#'
#' Publish a Darwin Core archive.
#'
#' @param staged_archive Character. Path to the staged archive.
#' @param filter List.
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
  split_archive,
  filter,
  dir = "archives"
) {

  system2("combine-dwca.sh", split_archive)

  n_out <- system(
    sprintf("unzip -p %s -x meta.xml eml.xml | wc -l", split_archive), TRUE
  )

  n_out <- as.integer(n_out) - 1L

  message(
    sprintf(
      "INFO [%s] Found %s records in archive, %s; file, occurrence.txt",
      Sys.time(),
      n_out,
      split_archive
    )
  )

  combined_archive <- file.path(dir, "combined", basename(split_archive))

  ans <-file.copy(split_archive, combined_archive, overwrite = TRUE)

  message(
    sprintf(
      "INFO [%s] %s published to %s", Sys.time(), split_archive,
      combined_archive
    )
  )

  ans

}
