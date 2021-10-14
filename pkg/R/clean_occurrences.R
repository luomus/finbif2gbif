#' Clean occurrences
#'
#' Clean occurrence files in an archive.
#'
#' @param archive Character. Path to the archive.
#' @param filters List.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' clean_occurrences("dwca.zip", list())
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @importFrom utils unzip zip
#' @export

clean_occurrences <- function(
  archive,
  filters
) {

  current_files <- vapply(filters, get_file_name, character(1L))

  old_files <- utils::unzip(archive, list = TRUE)

  obsolete_files <- setdiff(old_files[["Name"]], c("meta.xml", current_files))

  ans <- 0L

  if (length(obsolete_files) > 0) {

    message(
      sprintf(
        "[INFO] Removing obsolete occurrence files %s from %s",
        paste(obsolete_files, collapse = " "),
        archive
      )
    )

    ans <- utils::zip(archive, obsolete_files, "-djqr9X")

  }

  invisible(ans)

}
