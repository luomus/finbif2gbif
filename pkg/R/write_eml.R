#' Write EML
#'
#' Write an EML metadata file.
#'
#' @param archive Character. Path to a DarwinCore archive.
#' @param collection_id Collection ID.
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
#' @importFrom finbif finbif_occurrence scientific_name
#' @importFrom utils zip
#' @export

write_eml <- function(
  archive,
  collection_id,
  uuid,
  metadata,
  eml = config::get("eml")
) {

  eml <- get_metadata(collection_id, eml)

  eml <- list(
    packageId = paste0(uuid, "/v1.1"),
    system="http://gbif.org",
    scope="system",
    dataset = list(
      title = metadata[["title"]],
      abstract = metadata[["description"]],
      intellectualRights = metadata[["license"]],
      collectionCode = eml[["collectionCode"]],
      language = eml[["dataLanguage"]],
      methods = eml[["methods"]],
      coverage = EML::set_coverage(
        date = temporal_coverage(collection_id),
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

  ans <- finbif::finbif_occurrence(
    filter = c(collection = id, filters), select = var, aggregate = "records",
    order_by = paste0(sign, var), n = 1L
  )

  ans[[1L, 1L]]

}
