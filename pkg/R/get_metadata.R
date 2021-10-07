#' Get metadata
#'
#' Get FinBIF collection metadata needed for GBIF registration.
#'
#' @param collection_id Character. ID string of FinBIF collection.
#' @param metadata_fields List. Map of GBIF to FinBIF metadata fields to use.
#' @param org Character. GBIF organization key. Defaults to system environment
#'   variable, "GBIF_ORG".
#' @param installation Character. ID key of GBIF installation. Defaults to
#'   system environment variable, "GBIF_INSTALLATION".
#'
#' @return A list.
#' @examples \dontrun{
#'
#' get_metadata("HR.3991")
#'
#' }
#' @importFrom finbif finbif_collections
#' @export

get_metadata <- function(
  collection_id,
  metadata_fields = config::get("metadata"),
  org = Sys.getenv("GBIF_ORG"),
  installation = Sys.getenv("GBIF_INSTALLATION")
) {

  m <- finbif::finbif_collections(
    supercollections = TRUE, select = TRUE, filter = id == collection_id
  )

  licenses <- c(
    "MY.intellectualRightsCC-BY" =
      "https://creativecommons.org/licenses/by/4.0/legalcode",
    "MY.intellectualRightsCC0" =
      "https://creativecommons.org/publicdomain/zero/1.0/legalcode",
    "MY.intellectualRightsPD" =
      "Public Domain",
    "MY.intellectualRightsARR" =
      "All Rights Reserved"
  )

  m[["intellectual_rights"]] <- licenses[[m[["intellectual_rights"]]]]

  m[["language"]] <- ifelse(is.na(m[["language"]]), "eng", m[["language"]])

  c(
    list(
      publishingOrganizationKey = org,
      installationKey = installation,
      type = "OCCURRENCE"
    ),
    lapply(metadata_fields, function(x) m[[x]])
  )

}
