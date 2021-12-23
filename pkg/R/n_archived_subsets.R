#' Number of archived subsets
#'
#' Count the number of occurrence data subsets that have been archived.
#'
#' @param archive Darwin Core archive file.
#'
#' @return Integer.
#' @examples  \dontrun{
#'
#' n_archived_subsets("archive.zip")
#'
#' }
#' @export

n_archived_subsets <- function(archive) {

  df <- utils::unzip(archive, list = TRUE)

  archived <- grep("txt$", df[["Name"]], value = TRUE)

  ans <- length(archived)

  message(
    sprintf(
      "INFO [%s] The file, %s, has had %s of its subsets archived",
      Sys.time(),
      archive,
      ans
    )
  )

  ans

}
