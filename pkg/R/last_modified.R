#' Get last modified date
#'
#' Get the last modified data for FinBIF records
#'
#' @param filter List of named character vectors. Filters to apply to records.
#'
#' @return A Date object.
#' @examples \dontrun{
#'
#' last_modified(c(collection = "HR.3991"))
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @export

last_modified <- function(filter) {

  ans <- finbif::finbif_occurrence(
    filter = filter, select = "load_date", order_by = "-load_date",
    n = 1L
  )

  ans <- unlist(ans)

  as.Date(ans)

}
