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
#' @examples \dontrun{
#'
#' get_occurrences(
#'   c(collection = "HR.3991"), c("occurrenceID", "basisOfRecord"), 100
#' )
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @export

get_occurrences <- function(
  filter,
  select,
  n,
  quiet = TRUE
) {

  data <- finbif::finbif_occurrence(
    filter = filter, select = select, n = n, dwc = TRUE, quiet = quiet
  )

  data <- process_record_bases(data)

  data <- process_media(data)

  data

}

#' @noRd

process_record_bases <- function(data) {

  bor <- "basisOfRecord"

  has_bor <- bor %in% names(data)

  if (has_bor) {

    data[[bor]] <- record_bases[data[[bor]]]

  }

  data

}

#' @noRd

process_media <- function(data) {

  media <- "associatedMedia"

  license <- "license"

  has_media <- all(c(media, license) %in% names(data))

  if (has_media) {

    data[[license]] <- lapply(data[[license]] , function(x) licenses[x])

    data[[license]] <- lapply(
      data[[license]],
      function(x) ifelse(x == "All Rights Reserved", NA_character_, x)
    )

    data[[license]] <- lapply(
      data[[license]],
      function(x) {
        ifelse(x != c(x[!is.na(x)], NA_character_)[[1L]], NA_character_, x)
      }
    )

    data[[media]] <- mapply(
      function(x, y) ifelse(is.na(x), NA_character_, y),
      data[[license]],
      data[[media]],
      SIMPLIFY = FALSE
    )

    data[[license]] <- vapply(
      data[[license]],
      function(x) c(x[!is.na(x)], NA_character_)[[1L]], character(1L)
    )

    data[[media]] <- vapply(
      data[[media]], paste, character(1L), collapse = " | "
    )

  }

  data

}
