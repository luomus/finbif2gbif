#' Publish archive
#'
#' Publish a Darwin Core archive.
#'
#' @param staged_archive Character. Path to the staged archive.
#' @param dir Character. Path to the archive directory.
#' @param occurrence_file. Character. Name of occurrence core file.
#'
#' @return Character. The file path of the staged archive.
#' @examples \dontrun{
#'
#' publish_archive("stage/archive.zip")
#'
#' }
#' @importFrom xml2 read_xml as_list
#' @export
publish_archive <- function(
  staged_archive,
  dir = "archives",
  occurrence_file =  "occurrence.txt"
) {
  system2("combine-dwca.sh", staged_archive)

  n_out <- system(
    sprintf("unzip -p %s -x meta.xml eml.xml | wc -l", staged_archive), TRUE
  )

  n_out <- as.integer(n_out) - 1L

  message(
    sprintf(
      "INFO [%s] Found %s records in archive, %s; file: %s",
      format(Sys.time()),
      n_out,
      staged_archive,
      occurrence_file
    )
  )

  occ_file <- unz(staged_archive, occurrence_file)
  meta_file <- unz(staged_archive, "meta.xml")

  occ_file_columns <- read.delim(
    occ_file,
    quote = "",
    na.strings = "",
    nrows = 1
  )

  meta_file_columns <- xml2::read_xml(meta_file)
  meta_file_columns <- xml2::as_list(meta_file_columns)
  meta_file_columns <- meta_file_columns[["archive"]]
  meta_file_columns <- meta_file_columns[["core"]]
  meta_file_columns <- meta_file_columns[-1:-2]
  meta_file_columns <- unlist(lapply(meta_file_columns, attr, "index"))

  ans <- identical(length(occ_file_columns), length(meta_file_columns))

  if (ans) {
    combined_archive <- file.path(dir, "combined", basename(staged_archive))

    ans <- file.copy(staged_archive, combined_archive, overwrite = TRUE)

    message(
      sprintf(
        "INFO [%s] %s published to %s",
        format(Sys.time()),
        staged_archive,
        combined_archive
      )
    )
  }

  ans
}
