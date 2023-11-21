#' Write EML
#'
#' Write an EML metadata file.
#'
#' @param archive Character. Path to a DarwinCore archive.
#' @param collection_id Character. Collection ID.
#' @param uuid Character. GBIF ID.
#' @param metadata List.
#' @param eml List.
#'
#' @return The status value returned by the zip command, invisibly.
#' @examples \dontrun{
#'
#' registration <- get_registration(gbif_datasets(), "HR.3991")
#' uuid <- get_uuid(registration)
#' write_eml("dwca.zip", "HR.447", uuid, list())
#'
#' }
#' @importFrom EML set_coverage write_eml
#' @importFrom emld as_emld
#' @importFrom finbif finbif_occurrence scientific_name
#' @importFrom utils as.person person zip
#' @importFrom xml2 as_list as_xml_document read_xml write_xml
#' @export

write_eml <- function(
  archive,
  collection_id,
  uuid,
  metadata,
  eml = config::get("eml")
) {

  eml <- get_metadata(collection_id, eml)

  temp_cov <- temporal_coverage(collection_id)

  contact <- c(
    list(get_persons(eml[["contact"]], eml[["email"]])),
    list(
      emld::as_emld(
        utils::as.personList(
          utils::person("FinBIF", email = "helpdesk@laji.fi")
        )
      )
    )
  )

  eml <- list(
    packageId = uuid,
    dataset = list(
      title = metadata[["title"]],
      abstract = list(para = metadata[["description"]]),
      contact = contact,
      intellectualRights = metadata[["license"]],
      pubDate = Sys.Date(),
      language = eml[["dataLanguage"]],
      methods = list(
        sampling = list(
          samplingDescription = list(para = list(eml[["methods"]]))
        )
      ),
      coverage = EML::set_coverage(
        beginDate = temp_cov[[1L]],
        endDate  = temp_cov[[2L]],
        sci_names = taxonomic_coverage(collection_id),
        geographicDescription = eml[["geographicDescription"]],
        westBoundingCoordinate = geographic_coverage(
          collection_id, "lon_min_wgs84"
        ),
        eastBoundingCoordinate = geographic_coverage(
          collection_id, "lon_max_wgs84"
        ),
        northBoundingCoordinate = geographic_coverage(
          collection_id, "lat_max_wgs84"
        ),
        southBoundingCoordinate = geographic_coverage(
          collection_id, "lat_min_wgs84"
        )
      )
    )
  )

  tmpdir <- tempfile()
  on.exit(unlink(tmpdir))

  dir.create(tmpdir)

  file_name <- paste0(tmpdir, "/", "eml.xml")

  EML::write_eml(eml, file_name)

  eml <- xml2::read_xml(file_name)

  eml <- xml2::as_list(eml)

  eml[["eml"]][["dataset"]][["intellectualRights"]] <- get_license(
    eml[["eml"]][["dataset"]][["intellectualRights"]][[1L]]
  )

  eml[["eml"]][["dataset"]][["coverage"]][["geographicCoverage"]] <- clean_geo(
    eml[["eml"]][["dataset"]][["coverage"]][["geographicCoverage"]]
  )

  attr(eml[[1L]], "packageId") <- uuid

  eml <- xml2::as_xml_document(eml)

  xml2::write_xml(eml, file_name)

  message(sprintf("INFO [%s] Writing eml.xml file to %s", Sys.time(), archive))

  utils::zip(archive, file_name, "-jqr9X")

}

#' @noRd

taxonomic_coverage <- function(
  id, filters = config::get("filters")
) {

  kingdoms <- finbif::finbif_occurrence(
    filter = c(collection = id, filters), select = "kingdom_id",
    aggregate = "records", n = -1L
  )

  kingdoms <- vapply(
    kingdoms[["kingdom_id"]], finbif::scientific_name, character(1L)
  )

  data.frame(kingdom = kingdoms)

}

#' @noRd

temporal_coverage <- function(
  id, filters = config::get("filters")
) {

  ans <- c("", "")

  begin <- finbif::finbif_occurrence(
    filter = c(collection = id, filters), select = "date_start",
    aggregate = "records", order_by = "date_start", n = 1L
  )

  if (nrow(begin)) {

    end <- finbif::finbif_occurrence(
       filter = c(collection = id, filters), select = "date_end",
       aggregate = "records", order_by = "-date_end", n = 1L
    )

    ans <- c(begin[[1L, 1L]], end[[1L, 1L]])

  }

  ans

}

#' @noRd

geographic_coverage <- function(
  id, var, filters = config::get("filters")
) {

  sign <- ""

  if (grepl("max", var)) sign <- "-"

  x <- finbif::finbif_occurrence(
    filter = c(collection = id, filters), select = var, aggregate = "records",
    order_by = paste0(sign, var), n = 1L
  )

  ans <- ""

  if (nrow(x)) ans <- x[[1L, 1L]]

  ans

}

#' @noRd

get_persons <- function(persons, emails) {

  emails <- strsplit(emails, ",|;")
  emails <- emails[[1L]]
  emails <- trimws(emails)

  sep <- ";"

  is_comma_sep <- strsplit(persons, ",")
  is_comma_sep <- is_comma_sep[[1L]]
  is_comma_sep <- length(is_comma_sep) > 1L && grepl(" ", is_comma_sep[[1L]])

  if (is_comma_sep) sep <- ","

  persons <- strsplit(persons, sep)
  persons <- persons[[1L]]
  persons <- strsplit(persons, ",")
  persons <- lapply(persons, trimws)
  persons <- lapply(persons, rev)
  persons <- lapply(persons, paste, collapse = " ")

  for (i in seq_len(pmin(length(persons), length(emails)))) {

    persons[[i]] <- as.person(persons[[i]])

    persons[[i]] <- format(
      persons[[i]], include = c("given", "family", "email")
    )

    persons[[i]] <- as.person(persons[[i]])

  }

  persons <- do.call(c, persons)

  emld::as_emld(persons)

}

get_license <- function(x) {

  cc <- "Creative Commons"

  a <- "Attribution"

  switch(
    x,
    "https://creativecommons.org/licenses/by/4.0/legalcode" = license(
      x,
      paste(cc, a, "(CC-BY) 4.0 License")
    ),
    "https://creativecommons.org/publicdomain/zero/1.0/legalcode" = license(
      x,
      paste(cc, "(CC0) 1.0 License")
    ),
    "https://creativecommons.org/licenses/by-nc/4.0/legalcode" = license(
      x,
      paste(cc, a, "Non Commercial (CC-BY-NC) 4.0 License")
    ),
    "https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode" = license(
      x,
      paste(cc, a, "Non Commercial Share Alike (CC-BY-NC-SA) 4.0 License")
    ),
    "https://creativecommons.org/licenses/by-sa/4.0/legalcode" = license(
      x,
      paste(cc, a, "Share Alike (CC-SA) 4.0 License")
    ),
    "https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode" = license(
      x,
      paste(cc, a, "Non Commercial No Derivatives(CC-BY-NC) 4.0 License")
    ),
    "https://creativecommons.org/licenses/by-nd/4.0/legalcode" = license(
      x,
      paste(cc, a, "No Derivatives(CC-BY-NC) 4.0 License")
    ),
    list(
      para = list(
        "This work is licensed under ", list(citetitle = list(x)), "."
      )
    )
  )

}

license <- function(x, y) {

  list(
    para = list(
      "This work is licensed under a ",
      ulink = structure(list(citetitle = list(y)), url = x),
      "."
    )
  )

}

clean_geo <- function(x) {

  ans <- NULL

  bc <- x[["boundingCoordinates"]]

  if (is.null(bc) || length(unlist(bc)) < 4L) {

    x[["boundingCoordinates"]] <- NULL

  }

  if (length(x) > 0L) {

    ans <- x

  }

  ans

}
