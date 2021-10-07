#' Write metafile
#'
#' Write a Darwin Core archive meta data file.
#'
#' @param archive Character. Path to the archive.
#' @param filters List.
#' @param fields Character vector. The field names of the data files. Field
#'   names can optionally be prepended with a namespace (one of "dwc", "dwciri",
#'   "dc" or "dcterms") separated from the field by a ":". If no namespace is
#'   specified, "dwc" will be assumed.
#' @param id Integer. Indicates which field can be considered the record
#'   identifier. No ID field will be specified if \code{id} is not an integer
#'   between 1 and the number of fields specified.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' write_meta("dwca.zip", c("occurrenceID", "basisOfRecord"))
#'
#' }
#' @importFrom utils zip
#' @importFrom xml2 as_xml_document write_xml
#' @export

write_meta <- function(
  archive,
  filters,
  fields = config::get("fields"),
  id = 1
) {

  n_fields <- length(fields)

  core <- replicate(n_fields, structure(list()), FALSE)

  names(core) <- rep_len("field", n_fields)

  s <- seq_len(n_fields)

  for (i in s) {

    attr(core[[i]], "index") <- i - 1L

    field <- strsplit(fields[[i]], ":")

    field <- field[[1L]]

    ns <- field[[1L]]

    field <- rev(field)

    field <- field[[1L]]

    iri <- switch(
      ns,
      dwciri = "http://rs.tdwg.org/dwc/iri",
      dc = "http://purl.org/dc/elements/1.1",
      dcterms = "http://purl.org/dc/terms",
      "http://rs.tdwg.org/dwc/terms"
    )

    attr(core[[i]], "term") <- sprintf("%s/%s", iri, field)

  }

  iri <- "http://rs.tdwg.org/dwc"

  files <- vapply(filters, get_occurrence_file, character(1L))

  header <- list(files = list(location = as.list(files)))

  header[["id"]] <- switch(id %in% s, structure(list(), index = id - 1L))

  core <- structure(
    c(header, core),
    encoding = "UTF-8",
    fieldsTerminatedBy = "\\t",
    linesTerminatedBy = "\\n",
    fieldsEnclosedBy = "",
    ignoreHeaderLines = 1L,
    rowType = sprintf("%s/terms/Occurrence", iri)
  )

  meta <- list(
    archive = structure(list(core = core), xmlns = sprintf("%s/text/", iri))
  )

  meta <- xml2::as_xml_document(meta)

  tmpdir <- tempfile()

  dir.create(tmpdir)

  file_name <- paste0(tmpdir, "/", "meta.xml")

  xml2::write_xml(meta, file_name)

  utils::zip(archive, file_name, "-jqr9X")

}
