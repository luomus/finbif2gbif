#' Get occurrences
#'
#' Get occurrence records from FinBIF.
#'
#' @param filter List of named character vectors. Filters to apply to records.
#' @param select Character vector. Variables to return. If not specified, a
#'   default set of commonly used variables will be used. Use `"default_vars"`
#'   as a shortcut for this set. Variables can be deselected by prepending a `-`
#'   to the variable name. If only deselects are specified the default set of
#'   variables without the deselection will be returned.
#' @param n Integer. How many records to download/import.
#' @param quiet Logical. Suppress the progress indicator for multipage
#'   downloads.
#'
#' @return A finbif_occ object.
#' @examples \dontrun{
#'
#' get_occurrences(
#'   c(collection = "HR.3991"), c("occurrenceID", "basisOfRecord"), 100
#' )
#'
#' }
#' @importFrom finbif finbif_occurrence
#' @export

get_occurrences <- function(
  filter,
  select,
  n,
  quiet = TRUE
) {

  oq <- NULL

  if ("occurrenceRemarks" %in% select) {

    oq <- "occurrenceQuality"

  }

  type_vars <- NULL

  if ("typeStatus" %in% select) {

    type_vars <- c(
      "typeStatus",
      "typeSpecimenStatus",
      "scientificName",
      "typeSpecimenAuthor",
      "typeSpecimenBasionymePublication"
    )

  }

  verbatim_loc <- c(
    "county" = "verbatimCounty",
    "stateProvince" = "verbatimStateProvince",
    "country"= "verbatimCountry"
  )

  verbatim_loc <- verbatim_loc[intersect(select, names(verbatim_loc))]

  media_vars <- NULL

  if ("associatedMedia" %in% select) {

    media_vars <- c(
      id = "occurrenceID",
      type = "associatedMediaType",
      format = "associatedMedia",
      identifier = "associatedMedia",
      creator = "associatedMediaBy",
      license = "license"
    )

  }

  select_vars <- unname(verbatim_loc)
  select_vars <- c(select, oq, select_vars, type_vars)
  select_vars <- unique(select_vars)
  select_vars <- setdiff(select_vars, "associatedMedia")
  select_vars <- c(select_vars, media_vars)

  data <- finbif::finbif_occurrence(
    filter = filter,
    select = select_vars,
    n = n,
    dwc = TRUE,
    quiet = quiet
  )

  data <- process_record_bases(data)

  data <- process_recorded_by(data)

  data <- process_taxon_concept(data)

  data <- process_occurrence_remarks(data, oq)

  data <- process_location(data, verbatim_loc)

  data <- process_type_status(data, type_vars, select)

  data <- process_media(data, media_vars)

  for (i in names(data[["occurrence"]])) {

    if (inherits(data[["occurrence"]][[i]], "character")) {

      data[["occurrence"]][[i]] <- gsub(
        "\t|\r|\n|\r\n|\n\r"," ", data[["occurrence"]][[i]]
      )

    }

  }

  data

}

#' @noRd

process_record_bases <- function(data) {

  bor <- "basisOfRecord"

  has_bor <- bor %in% names(data)

  if (has_bor) {

    data[[bor]] <- record_bases[data[[bor]]]

  }

  data

}

#' @noRd

process_recorded_by <- function(data) {

  rb <- "recordedBy"

  has_rb <- rb %in% names(data)

  if (has_rb) {

    data[[rb]] <- vapply(data[[rb]], pipe_collapse, character(1L))

  }

  data

}

#' @noRd

process_taxon_concept <- function(data) {

  tc <- "taxonConceptID"

  has_tc <- tc %in% names(data)

  if (has_tc) {

    data[[tc]] <- vapply(data[[tc]], pipe_collapse, character(1L))

  }

  data

}

#' @noRd

process_occurrence_remarks <- function(data, oq) {

  if (!is.null(oq)) {

    or <- "occurrenceRemarks"

    data[[or]] <- ifelse(is.na(data[[or]]), "", paste0("\n", data[[or]]))

    data[[or]] <- paste0(
      "Quality assessment: ",
      ifelse(data[[oq]] == "NEUTRAL", "UNASSESSED", data[[oq]]),
      data[[or]]
    )

    data[[oq]] <- NULL

  }

  data

}

#' @noRd

process_location <- function(data, verbatim_loc) {

  for (i in seq_along(verbatim_loc)) {

    var_name <- names(verbatim_loc)[[i]]

    var <- verbatim_loc[[i]]

    has_var <- var_name %in% names(data)

    if (has_var) {

      data[[var_name]] <- ifelse(
        is.na(data[[var_name]]), data[[var]], data[[var_name]]
      )

    }

    data[[var]] <- NULL

  }

  data

}

#' @noRd

process_type_status <- function(data, type_vars, select) {

  if (!is.null(type_vars)) {

    data[["typeStatus"]] <- unlist(
      .mapply(paste_type_status, data[type_vars], NULL)
    )

    data[setdiff(type_vars, select)] <- NULL

  }

  data

}

#' @noRd
#' @importFrom tidyr unnest
#' @importFrom rlang .data

process_media <- function(data, media_vars) {

  media_data <- NULL

  has_media <- all(names(media_vars) %in% names(data))

  if (has_media) {

    media_data <- data[names(media_vars)]

    data[names(media_vars)] <- NULL

    media_data[["type"]] <- lapply(
      media_data[["type"]],
      function(x) ifelse(x == "IMAGE", "StillImage", NA_character_)
    )

    media_data[["format"]] <- lapply(media_data[["format"]], tools::file_ext)

    media_data[["format"]] <- lapply(media_data[["format"]], tolower)

    media_data[["format"]] <- lapply(
      media_data[["format"]], function(x) ifelse(x == "jpg", "jpeg", x)
    )

    media_data[["format"]] <- lapply(
      media_data[["format"]],
      function(x) ifelse(x == "jpeg", "image/jpeg", NA_character_)
    )

    media_data[["license"]] <- lapply(
      media_data[["license"]], function(x) licenses[x]
    )

    media_data[["license"]] <- lapply(
      media_data[["license"]],
      function(x) ifelse(x == "All Rights Reserved", NA_character_, x)
    )

    media_data <- tidyr::unnest(media_data, -.data[["id"]])

    media_data <- media_data[!is.na(media_data[["license"]]), , drop = FALSE]

    if (nrow(media_data) < 1L) {

      media_data <- NULL

    }

  }

  list(occurrence = data, media = media_data)

}

#' @noRd

paste_type_status <- function(
  typeStatus,
  typeSpecimenStatus,
  scientificName,
  typeSpecimenAuthor,
  typeSpecimenBasionymePublication
) {

  ans <- ""

  if (typeStatus) {

    typeSpecimenStatus <- na.omit(typeSpecimenStatus)
    typeSpecimenStatus <- types[typeSpecimenStatus]

    scientificName <- na.omit(scientificName)

    typeSpecimenAuthor <- na.omit(typeSpecimenAuthor)

    typeSpecimenBasionymePublication <- na.omit(
      typeSpecimenBasionymePublication
    )

    ans <- paste(
      typeSpecimenStatus, scientificName, typeSpecimenAuthor, "-",
      typeSpecimenBasionymePublication
    )

    ans <- paste(ans, collapse = " | ")

    ans <- gsub("\\s+", " ", ans)

    ans <- gsub("^ *-|- *$", "", ans)

    ans <- trimws(ans)

  }

  ans

}

#' @noRd

pipe_collapse <- function(x) {

  x <- na.omit(x)

  ans <- ""

  if (length(x) > 0L) {

    ans <- paste(x, collapse = " | ")

  }

  ans

}
