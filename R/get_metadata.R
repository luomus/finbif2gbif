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

  m <- finbif::finbif_collections(supercollections = TRUE, select = TRUE)

  ind <- m[["id"]] == collection_id

  m <- m[ind, ]

  m[["type"]] <- "OCCURRENCE"

  m[["metadata_language"]] <- "eng"

  m[["intellectual_rights"]] <- ifelse(
    is.na(m[["intellectual_rights"]]),
    "All Rights Reserved",
    licenses[[m[["intellectual_rights"]]]]
  )

  m[["language"]] <- ifelse(
    is.na(m[["language"]]), "mul", languages[[m[["language"]]]]
  )

  message(
    sprintf(
      "INFO [%s] Metadata for collection %s retrieved from FinBIF",
      format(Sys.time()),
      collection_id
    )
  )

  c(
    list(
      publishingOrganizationKey = org,
      installationKey = installation
    ),
    lapply(metadata_fields, function(x) m[[x]])
  )

}

#' @noRd

languages <- c(
  "english" = "eng",
  "estonian" = "est",
  "finnish" = "fin",
  "mixed" = "mul",
  "russian" = "rus",
  "swedish" = "swe"
)
