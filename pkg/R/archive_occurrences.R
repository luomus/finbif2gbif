#' Archive occurrences
#'
#' Archive occurrence records in a Darwin Core archive.
#'
#' @param archive Character. Path to the archive.
#' @param file_name Character. The name of the file to write to the archive.
#' @param filter List of named character vectors. Filters to apply to records.
#' @param select Character vector. Variables to return. If not specified, a
#'   default set of commonly used variables will be used. Use `"default_vars"`
#'   as a shortcut for this set. Variables can be deselected by prepending a `-`
#'   to the variable name. If only deselects are specified the default set of
#'   variables without the deselection will be returned.
#' @param n Integer. How many records to download/import.
#' @param quiet Logical. Suppress the progress indicator for multipage
#'   downloads.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' archive_occurrences(
#'   "dwca.zip", "occurrence.txt", list(collection = "HR.139"),
#'    c("occurrenceID", "basisOfRecord")
#' )
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @export

archive_occurrences <- function(
  archive,
  file_name,
  filter,
  select = sub("^.*:", "", config::get("fields")),
  n = config::get("nmax"),
  quiet = TRUE
) {


  occ <- get_occurrences(filter, select, as.integer(n), quiet = quiet)

  write_occurrences(occ, archive, file_name)

}
