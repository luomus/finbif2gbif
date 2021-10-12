#' Count occurrences
#'
#' Count the number of occurrences.
#'
#' @param x Object to count occurrences for.
#' @param ... Arguments passed to methods.
#'
#' @return Integer.
#' @examples  \dontrun{
#'
#' count_occurrences(list(collection = "HR.3991"))
#'
#' }
#' @export

count_occurrences <- function(
  x,
  ...
) {

  UseMethod("count_occurrences")

}

#' @noRd
#' @importFrom finbif finbif_occurrence
#' @export

count_occurrences.default <- function(
  x,
  ...
) {

  finbif::finbif_occurrence(filter = x, count_only = TRUE)

}

#' @noRd
#' @export

count_occurrences.archive_file <- function(
  x,
  file,
  ...
) {

  df <- utils::unzip(x, list = TRUE)

  if (file %in% df[["Name"]]) {

    con <- unz(x, file, "rb")
    on.exit(close(con))

    nlines <- 0L
    chunk <- as.raw(0L)

    while (length(chunk) > 0L) {

       chunk <- readBin(con, "raw", 65536L)
       nlines <- nlines + sum(chunk == as.raw(10L))

    }

    nlines - 1L

  } else {

    0L

  }

}
