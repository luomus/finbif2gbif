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
#' @importFrom utils capture.output
#' @export

count_occurrences.default <- function(
  x,
  ...
) {

  n <- finbif::finbif_occurrence(filter = x, select = "record_id", n = 1L)

  n <- attr(n, "nrec_avl")

  message(
    sprintf(
      "INFO [%s] Found %s occurrence records in FinBIF for filter: %s",
      format(Sys.time()),
      n,
      paste(trimws(utils::capture.output(dput(as.list(x)))), collapse = " ")
    )
  )

  n

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

    n <- nlines - 1L

  } else {

    n <- 0L

  }

  message(
    sprintf(
      "INFO [%s] Found %s records in archive, %s; file, %s",
      format(Sys.time()),
      n,
      x,
      file
    )
  )

  n

}
