#' @noRd
#' @importFrom utils hasName zip
#' @importFrom xml2 as_list as_xml_document read_xml write_xml

media_extension <- function(archive, meta_file_name, media_file_name) {

  con <- unz(archive, "meta.xml", "rb")
  on.exit(close(con))

  meta <- xml2::read_xml(con)

  meta <- xml2::as_list(meta)

  if (!utils::hasName(meta[["archive"]], "extension")) {

    meta[["archive"]][["extension"]] <- media_extension_xml()

  }

  bn <- basename(media_file_name)

  files <- meta[["archive"]][["extension"]][["files"]]

  if (!bn %in% unlist(files)) {

    meta[["archive"]][["extension"]][["files"]] <- c(
      files, list(location = list(bn))
    )

  }

  meta <- xml2::as_xml_document(meta)

  xml2::write_xml(meta, meta_file_name)

  utils::zip(archive, meta_file_name, "-jqr9X")

}

media_extension_xml <- function() {

  fields <- c("type", "format", "identifier", "creator", "license")

  extension <- replicate(6L, structure(list()), FALSE)

  names(extension) <- c("coreid", rep_len("field", 5L))

  attr(extension[[1L]], "index") <- 0L

  for (i in seq_len(5L)) {

    attr(extension[[i + 1L]], "index") <- i

    attr(extension[[i + 1L]], "term") <- sprintf(
      "http://purl.org/dc/terms/%s", fields[[i]]
    )

  }

  extension <- structure(
    c(list(files = list()), extension),
    encoding = "UTF-8",
    fieldsTerminatedBy = "\\t",
    linesTerminatedBy = "\\n",
    fieldsEnclosedBy = "",
    ignoreHeaderLines = 1L,
    rowType = "http://rs.gbif.org/terms/1.0/Multimedia"
  )

  extension

}
