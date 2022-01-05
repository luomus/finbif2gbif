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
#' @importFrom utils as.personList zip
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

  contacts <- get_persons(eml[["contact"]], eml[["email"]])

  contact <- contacts

  associatedParties <- NULL

  if (!inherits(contacts, "emld")) {

    contact <- contacts[[1L]]

    associatedParties <- contacts[-1L]

  }

  eml <- list(
    packageId = uuid,
    dataset = list(
      title = metadata[["title"]],
      abstract = list(para = metadata[["description"]]),
      contact = contact,
      associatedParties = associatedParties,
      intellectualRights = metadata[["license"]],
      pubDate = Sys.Date(),
      language = eml[["dataLanguage"]],
      methods = eml[["methods"]],
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

  begin <- finbif::finbif_occurrence(
    filter = c(collection = id, filters), select = "date_start",
    aggregate = "records", order_by = "date_start", n = 1L
  )

  end <- finbif::finbif_occurrence(
     filter = c(collection = id, filters), select = "date_end",
     aggregate = "records", order_by = "-date_end", n = 1L
  )

  c(begin[[1L, 1L]], end[[1L, 1L]])

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

  ans <- NA_real_

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

  persons <- utils::as.personList(persons)

  emld::as_emld(persons)

}
