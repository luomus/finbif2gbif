#' Get last modified date
#'
#' Get the last modified data for FinBIF records
#'
#' @param x Object to get last modified time for.
#' @param ... Arguments passed to methods.
#'
#' @return A Date object.
#' @examples \dontrun{
#'
#' last_modified(list(collection = "HR.3991"))
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @export

last_mod <- function(
  x,
  ...
) {

  UseMethod("last_mod")

}

#' @noRd
#' @export

last_mod.default <- function(
  x,
  ...
) {

  ans <- finbif::finbif_occurrence(
    filter = x, select = "load_date", order_by = "-load_date", n = 1L
  )

  if (is.na(ans[["load_date"]][[1L]])) {

    ans <- finbif::finbif_occurrence(
      filter = c(collection = x[["collection"]]), select = "load_date",
      order_by = "-load_date", aggregate = "document", n = 1L
    )

    ans[["n_documents"]] <- NULL

  }

  ans <- unlist(ans)

  message(
    sprintf("INFO [%s] FinBIF records last modified on %s", Sys.time(), ans)
  )

  as.Date(ans)

}

#' @noRd
#' @importFrom utils unzip
#' @export

last_mod.archive_file <- function(
  x,
  file_name,
  ...
) {

  df <- utils::unzip(x, list = TRUE)

  ans <- df[df[["Name"]] == file_name, "Date"]

  if (identical(length(ans), 0L)) {

    ans <- as.POSIXct(Inf)

  }

  message(
    sprintf(
      "INFO [%s] Archive, %s; file, %s last modified on %s",
      Sys.time(),
      x,
      file_name,
      format(ans)
    )
  )

  ans

}

#' @noRd
#' @export

last_mod.col_id <- function(
  x,
  ...
) {

  ans <- attr(x, "last_mod")

  message(
    sprintf(
      "INFO [%s] Collection %s metadata last modified on %s",
      Sys.time(),
      x,
      format(ans)
    )
  )

  ans

}

#' @noRd
#' @export

last_mod.registration <- function(
  x,
  ...
) {

  ans <- attr(x, "last_mod")

  message(
    sprintf(
      "INFO [%s] GBIF dataset %s metadata last modified on %s",
      Sys.time(),
      attr(x, "key"),
      format(ans)
    )
  )

  ans

}
