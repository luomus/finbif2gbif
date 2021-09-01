#' Archive occurrences
#'
#' Archive occurrence records in a Darwin Core archive.
#'
#' @param filter List of named character vectors. Filters to apply to records.
#' @param select Character vector. Variables to return. If not specified, a
#'   default set of commonly used variables will be used. Use `"default_vars"`
#'   as a shortcut for this set. Variables can be deselected by prepending a `-`
#'   to the variable name. If only deselects are specified the default set of
#'   variables without the deselection will be returned.
#' @param archive Character. Path to the archive.
#' @param file_name Character. The name of the file to write to the archive.
#' @param quiet Logical. Suppress the progress indicator for multipage
#'   downloads.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' archive_occurrences(
#'   c(collection = "HR.3991"), c("occurrenceID", "basisOfRecord"), "dwca.zip"
#' )
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @export

archive_occurrences <- function(
  filter, select, archive, file_name = "occurrence.txt", quiet = TRUE
) {

  n <- finbif::finbif_occurrence(filter = filter, count_only = TRUE)

  occ <- get_occurrences(filter, select, n, quiet = TRUE)

  write_occurrences(occ, archive)

}
