#' Write metafile
#'
#' Write a Darwin Core archive metadata file.
#'
#' @param archive Character. Path to the archive.
#' @param filters List.
#' @param fields Character vector. The field names of the data files. Field
#'   names can optionally be prepended with a namespace (one of "dwc", "dwciri",
#'   "dc" or "dcterms") separated from the field by a ":". If no namespace is
#'   specified, "dwc" will be assumed.
#' @param facts List of extra variables to be extracted from record,
#'   event and document "facts".
#' @param combine Named list of variables to combine.
#' @param collections Character. Path to collections.json file.
#' @param id Integer. Indicates which field can be considered the record
#'   identifier. No ID field will be specified if \code{id} is not an integer
#'   between 1 and the number of fields specified.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' write_meta(
#'   "dwca.zip", list(collection = "HR.447"), c("occurrenceID", "basisOfRecord")
#' )
#'
#' }
#' @importFrom jsonlite read_json
#' @importFrom utils unzip zip
#' @importFrom xml2 as_xml_document write_xml
#' @export

write_meta <- function(
  archive,
  filters,
  fields = config::get("fields"),
  facts = config::get("facts"),
  combine = config::get("combine"),
  collections = "collections.json",
  id = 1
) {

  facts <- names(facts)

  fields <- setdiff(fields, "associatedMedia")

  fields <- c(fields, facts)

  fields <- setdiff(fields, unlist(combine))

  fields <- c(fields, names(combine))

  collection_id <- attr(filters, "collection_id")

  collections <- jsonlite::read_json(collections, simplifyVector = FALSE)

  collection_ids <- vapply(collections, getElement, "", "id")

  collection <- collections[[which(collection_ids == collection_id)]]

  n_fields <- length(fields) + length(collection)

  core <- replicate(n_fields, structure(list()), FALSE)

  names(core) <- rep_len("field", n_fields)

  s <- seq_len(n_fields - length(collection))

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
      eco = "http://rs.tdwg.org/eco/terms",
      ecoiri = "http://rs.tdwg.org/eco/iri",
      "http://rs.tdwg.org/dwc/terms"
    )

    attr(core[[i]], "term") <- sprintf("%s/%s", iri, field)

  }

  iri <- "http://rs.tdwg.org/dwc"

  m <- get_metadata(collection_id, list(title = "long_name"))

  attr(core[[i + 1L]], "default") <- m[["title"]]

  attr(core[[i + 1L]], "term") <- sprintf("%s/terms/%s", iri, "datasetName")

  if (!is.null(collection[["institutionID"]])) {

    attr(core[[i + 2L]], "default") <- paste0(
      "https://scientific-collections.gbif.org/institution/",
      collection[["institutionID"]]
    )

    attr(core[[i + 2L]], "term") <- sprintf("%s/terms/%s", iri, "institutionID")

  }

  if (!is.null(collection[["collectionID"]])) {

    attr(core[[i + 3L]], "default") <- paste0(
      "https://scientific-collections.gbif.org/collection/",
      collection[["collectionID"]]
    )

    attr(core[[i + 3L]], "term") <- sprintf("%s/terms/%s", iri, "collectionID")

  }

  files <- lapply(filters, get_file_name)

  files <- lapply(files, as.list)

  names(files) <- rep_len("location", length(files))

  header <- list(files = files)

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
    archive = structure(
      list(core = core), xmlns = sprintf("%s/text/", iri), metadata = "eml.xml"
    )
  )

  files_in_archive <- character()

  if (file.exists(archive)) {

    files_in_archive <- utils::unzip(archive, list = TRUE)

    files_in_archive <- files_in_archive[["Name"]]

  }

  media_files <- vapply(filters, get_file_name, "", prefix = "media")

  media_files <- intersect(media_files, files_in_archive)

  if (length(media_files) > 0L) {

    meta[["archive"]][["extension"]] <- media_extension_xml()

    media_files <- lapply(media_files, as.list)

    names(media_files) <- rep_len("location", length(media_files))

    meta[["archive"]][["extension"]][["files"]] <- media_files

  }

  meta <- xml2::as_xml_document(meta)

  tmpdir <- tempfile()
  on.exit(unlink(tmpdir))

  dir.create(tmpdir)

  file_name <- paste0(tmpdir, "/", "meta.xml")

  xml2::write_xml(meta, file_name)

  message(
    sprintf(
      "INFO [%s] Writing meta.xml file to %s", format(Sys.time()), archive
    )
  )

  utils::zip(archive, file_name, "-jqr9X")

}
