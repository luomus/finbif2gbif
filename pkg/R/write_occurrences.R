#' Write occurrences
#'
#' Write occurrence records to a Darwin Core archive.
#'
#' @param data A data.frame. Occurrence records.
#' @param archive Character. Path to the archive.
#' @param file_name Character. The name of the file to write to the archive.
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
#' @export

write_occurrences <- function(data, archive, file_name = "occurrence.txt") {

  op <- options()
  on.exit(options(op))

  tmpdir <- tempfile()

  dir.create(tmpdir)

  file_name <- paste0(tmpdir, "/", file_name)

  options(scipen = 99L)

  utils::write.table(
    data,
    file_name,
    quote = FALSE,
    sep = "\t",
    na = "",
    row.names = FALSE,
    fileEncoding = "UTF-8"
  )

  utils::zip(archive, file_name, "-jqr9X")

}
