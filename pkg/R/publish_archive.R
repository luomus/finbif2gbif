#' Get archive file path
#'
#' Get the file path of an archive for a collection.
#'
#' @param staged_archive Character. Path to the staged archive.
#' @param filter List.
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
  filter,
  dir = "archives"
) {

  split_archive <- file.path(dir, "split", basename(staged_archive))

  class(split_archive) <- "archive_file"

  combined_archive <- file.path(dir, "combined", basename(staged_archive))

  file.copy(staged_archive, split_archive, overwrite = TRUE)

  system2("combine-dwca.sh", split_archive)

  n_in <- attr(filter, "n")

  n_out <- count_occurrences(split_archive, "occurrence.txt")

  cond <- identical(n_out, n_in)

  names(cond) <- sprintf(
    "Count mismatch for file %s in %s [n = %s] & collection %s [n = %s]",
    "occurrence.txt",
    combined_archive,
    n_out,
    attr(filter, "collection_id"),
    n_in
  )

  do.call(stopifnot, list(cond))

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
