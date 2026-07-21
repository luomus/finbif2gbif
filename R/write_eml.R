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

  if (is.na(eml[["url"]])) {
    eml[["url"]] <- paste0("https://tun.fi/", collection_id)
  }

  org <- list(logo = "https://cdn.laji.fi/images/logos/LAJI_FI_sin.png")
  if (!identical("", Sys.getenv("GBIF_ORG"))) org <- get_org()

  contact <- eml[["contact"]]
  email <- eml[["email"]]
  datasetSubtype <- eml[["datasetSubtype"]]
  url <- eml[["url"]]

  if (is.na(eml[["methods"]])) eml[["methods"]] <- ""

  eml <- list(
    packageId = uuid,
    dataset = list(
      title = metadata[["title"]],
      creator = list(organizationName = list(eml[["creator"]])),
      contact = list(get_persons(contact, email)),
      pubDate = Sys.Date(),
      language = eml[["dataLanguage"]],
      abstract = list(para = metadata[["description"]]),
      intellectualRights = metadata[["license"]],
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
      ),
      methods = list(
        methodStep = list(description = list(para = list(""))),
        sampling = list(
          studyExtent = list(description = list(para = list(""))),
          samplingDescription = list(para = list(eml[["methods"]]))
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

  eml[["eml"]][["dataset"]] <- list(
    alternateIdentifier = list(uuid),
    alternateIdentifier = list(
      paste0(Sys.getenv("ENDPOINTS"), "/archive/", collection_id)
    ),
    title = eml[["eml"]][["dataset"]][["title"]],
    creator = eml[["eml"]][["dataset"]][["creator"]],
    pubDate = eml[["eml"]][["dataset"]][["pubDate"]],
    language = eml[["eml"]][["dataset"]][["language"]],
    abstract = eml[["eml"]][["dataset"]][["abstract"]],
    keywordSet = list(
      keyword = list("Occurrence"),
      keywordThesaurus = list(
        paste(
          "GBIF Dataset Type Vocabulary:",
          "http://rs.gbif.org/vocabulary/gbif/dataset_type_2015-07-10.xml"
        )
      )
    ),
    keywordSet = list(
      keyword = list(
        switch(
          datasetSubtype %||% "",
          MY.collectionTypeSpecimens = "Specimen",
          "Observation"
        )
      ),
      keywordThesaurus = list(
        paste(
          "GBIF Dataset Subtype Vocabulary:",
          "http://rs.gbif.org/vocabulary/gbif/dataset_subtype.xml"
        )
      )
    ),
    intellectualRights = get_license(
      eml[["eml"]][["dataset"]][["intellectualRights"]][[1L]]
    ),
    licensed = get_license_id(
      eml[["eml"]][["dataset"]][["intellectualRights"]][[1L]]
    ),
    distribution = list(online = list(url = list(url))),
    coverage = eml[["eml"]][["dataset"]][["coverage"]],
    contact = eml[["eml"]][["dataset"]][["contact"]],
    contact = list(
      organizationName = list("FinBIF"),
      electronicMailAddress = list("helpdesk@laji.fi")
    ),
    methods = eml[["eml"]][["dataset"]][["methods"]],
    additionalMetadata = list(
      metadata = list(
        gbif = list(
          dateStamp = list(attr(collection_id, "created")),
          hierarchyLevel = list("dataset"),
          resourceLogoUrl = list(org[["logoUrl"]]),
          "dc:replaces" = list(uuid)
        )
      )
    )
  )

  eml[["eml"]][["dataset"]][["coverage"]][["geographicCoverage"]] <- clean_geo(
    eml[["eml"]][["dataset"]][["coverage"]][["geographicCoverage"]]
  )

  attr(eml[["eml"]][["dataset"]][["distribution"]], "scope") <- "document"

  url <- eml[["eml"]][["dataset"]][["distribution"]][["online"]][["url"]]

  attr(url, "function") <- "information"

  eml[["eml"]][["dataset"]][["distribution"]][["online"]][["url"]] <- url

  attr(eml[["eml"]][["dataset"]][["title"]], "xml:lang") <- "eng"

  attr(eml[["eml"]], "packageId") <- uuid
  attr(eml[["eml"]], "xmlns:dc")  <- "http://purl.org/dc/terms/"
  attr(eml[["eml"]], "system") <- "http://gbif.org"
  attr(eml[["eml"]], "scope") <- "system"
  attr(eml[["eml"]], "xml:lang") <- "eng"
  attr(eml[["eml"]], "xsi:schemaLocation") <- sub(
    "https://eml.ecoinformatics.org/eml-2.2.0/eml.xsd",
    "https://rs.gbif.org/schema/eml-gbif-profile/1.3/eml.xsd",
    attr(eml[["eml"]], "schemaLocation"),
    fixed = TRUE
  )
  attr(eml[["eml"]], "schemaLocation") <- NULL

  names(eml) <- "eml:eml"

  eml <- xml2::as_xml_document(eml)

  xml2::write_xml(eml, file_name)

  message(
    sprintf("INFO [%s] Writing eml.xml file to %s", format(Sys.time()), archive)
  )

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

    persons[[i]] <- sprintf("%s <%s>", persons[[i]], emails[[i]])

  }

  for (i in seq_along(persons)) {

    persons[[i]] <- as.person(persons[[i]])

    persons[[i]] <- format(
      persons[[i]], include = c("given", "family", "email")
    )

    persons[[i]] <- as.person(persons[[i]])

  }

  persons <- do.call(c, persons)

  emld::as_emld(persons)

}

#' @noRd
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
      paste(cc, a, "No Derivatives (CC-BY-NC) 4.0 License")
    ),
    list(
      para = list(
        "This work is licensed under ", list(citetitle = list(x)), "."
      )
    )
  )
}

#' @noRd
license <- function(x, y) {

  list(
    para = list(
      "This work is licensed under a ",
      ulink = structure(list(citetitle = list(y)), url = x),
      "."
    )
  )

}

#' @noRd
get_license_id <- function(x) {

  cc <- "Creative Commons"

  switch(
    x,
    "https://creativecommons.org/licenses/by/4.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Attribution 4.0 International")
      ),
      url = list("https://spdx.org/licenses/CC-BY-4.0.html"),
      identifier = list("CC-BY-4.0")
    ),
    "https://creativecommons.org/publicdomain/zero/1.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Zero v1.0 Universal")
      ),
      url = list("https://spdx.org/licenses/CC0-1.0.html"),
      identifier = list("CC0-1.0")
    ),
    "https://creativecommons.org/licenses/by-nc/4.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Attribution Non Commercial 4.0 International")
      ),
      url = list("https://spdx.org/licenses/CC-BY-NC-4.0.html"),
      identifier = list("CC-BY-NC-4.0")
    ),
    "https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Attribution Non Commercial Share Alike 4.0 International")
      ),
      url = list("https://spdx.org/licenses/CC-BY-NC-SA-4.0.html"),
      identifier = list("CC-BY-NC-SA-4.0")
    ),
    "https://creativecommons.org/licenses/by-sa/4.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Attribution Share Alike 4.0 International")
      ),
      url = list("https://spdx.org/licenses/CC-BY-SA-4.0.html"),
      identifier = list("CC-BY-SA-4.0")
    ),
    "https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Attribution Non Commercial No Derivatives 4.0 International")
      ),
      url = list("https://spdx.org/licenses/CC-BY-NC-ND-4.0.html"),
      identifier = list("CC-BY-NC-ND-4.0")
    ),
    "https://creativecommons.org/licenses/by-nd/4.0/legalcode" = list(
      licenseName = list(
        paste(cc, "Attribution No Derivatives 4.0 International")
      ),
      url = list("https://spdx.org/licenses/CC-BY-ND-4.0.html"),
      identifier = list("CC-BY-ND-4.0")
    )
  )
}

#' @noRd
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

#' @noRd
#' @importFrom httr authenticate content RETRY status_code
#' @importFrom jsonlite fromJSON
get_org <- function(
    org = Sys.getenv("GBIF_ORG"),
    url = Sys.getenv("GBIF_API"),
    user = Sys.getenv("GBIF_USER"),
    pass = Sys.getenv("GBIF_PASS")
) {
  auth <- httr::authenticate(user, pass)

  res <- httr::RETRY(
    "GET",
    url = url,
    config = auth,
    path = sprintf("v1/organization/%s", org)
  )

  status <- httr::status_code(res)

  ok <- identical(status, 200L)

  stopifnot("Failed to fetch org" = ok)

  res <- httr::content(res, "text", encoding = "UTF-8")

  jsonlite::fromJSON(res, simplifyVector = FALSE)
}
