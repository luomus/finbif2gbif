#' Get occurrences
#'
#' Get occurrence records from FinBIF.
#'
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
#' @return A finbif_occ object.
#' @examples
#' get_occurrences(
#'   c(collection = "HR.3991"), c("occurrenceID", "basisOfRecord"), 100
#' )
#' @importFrom finbif finbif_occurrence
#' @export

get_occurrences <- function(filter, select, n, quiet = TRUE) {

  data <- finbif::finbif_occurrence(
    filter = filter, select = select, n = n, dwc = TRUE, quiet = quiet
  )

  bor <- "basisOfRecord"

  has_bor <- bor %in% names(data)

  if (has_bor) {

    data[[bor]] <- record_bases[data[[bor]]]

  }

  data

}
