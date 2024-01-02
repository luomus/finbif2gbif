#' Write occurrences
#'
#' Write occurrence records to a Darwin Core archive.
#'
#' @param data A data.frame. Occurrence records.
#' @param archive Character. Path to the archive.
#' @param file_name Character. The name of the file to write to the archive.
#' @param media_file_name Character. The name of the media extension file to
#'   write to the archive.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' data <- get_occurrences(
#'   c(collection = "HR.3991"), c("occurrenceID", "basisOfRecord"), 100
#' )
#' write_occurrences(data, "dwca.zip")
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @importFrom utils write.table zip
#' @export

write_occurrences <- function(
  data,
  archive,
  file_name = "occurrence.txt",
  media_file_name = "media.txt"
) {

  op <- options()
  on.exit(options(op))
  options(scipen = 99L)

  tmpdir <- tempfile()
  dir.create(tmpdir)
  on.exit(unlink(tmpdir, TRUE), add = TRUE)

  file_name <- paste0(tmpdir, "/", file_name)

  if (!is.null(data[["media"]])) {

    media_file_name <- paste0(tmpdir, "/", media_file_name)

    meta_file_name <- paste0(tmpdir, "/", "meta.xml")

    message(
      sprintf(
        "INFO [%s] Writing media records to %s in archive %s",
        Sys.time(),
        basename(media_file_name),
        archive
      )
    )

    utils::write.table(
      data[["media"]],
      media_file_name,
      quote = FALSE,
      sep = "\t",
      na = "",
      row.names = FALSE,
      fileEncoding = "UTF-8"
    )

    media_extension(archive, meta_file_name, media_file_name)

    utils::zip(archive, c(media_file_name, meta_file_name), "-jqr9X")

  }

  message(
    sprintf(
      "INFO [%s] Writing occurrence records to %s in archive %s",
      Sys.time(),
      basename(file_name),
      archive
    )
  )

  utils::write.table(
    data[["occurrence"]],
    file_name,
    quote = FALSE,
    sep = "\t",
    na = "",
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )

  utils::zip(archive, file_name, "-jqr9X")

}
