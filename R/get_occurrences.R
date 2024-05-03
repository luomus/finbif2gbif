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
#' @param facts List of extra variables to be extracted from record,
#'   event and document "facts".
#' @param combine List of fields to combine.
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
  facts,
  combine,
  n,
  quiet = TRUE
) {

  oq <- NULL
  dk <- NULL
  rk <- NULL

  if ("occurrenceRemarks" %in% select) {

    oq <- "occurrenceQuality"
    dk <- "documentKeywords"
    rk <- "occurrenceKeywords"

  }

  type_vars <- NULL

  if ("typeStatus" %in% select) {

    type_vars <- c(
      "typeStatus",
      "typeSpecimenStatus",
      "typeSpecimenTaxon",
      "typeSpecimenAuthor"
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
  select_vars <- c(select, oq, dk, rk, select_vars, type_vars)
  select_vars <- unique(select_vars)
  select_vars <- setdiff(select_vars, "associatedMedia")
  select_vars <- c(select_vars, media_vars)

  data <- finbif::finbif_occurrence(
    filter = filter,
    select = select_vars,
    facts = unlist(facts),
    n = n,
    dwc = TRUE,
    quiet = quiet
  )

  data <- process_points(data)

  data <- process_record_bases(data)

  data <- process_recorded_by(data)

  data <- process_facts(data, facts)

  data <- process_taxon_concept(data)

  data <- process_occurrence_remarks(data, oq, dk, rk)

  data <- process_location(data, verbatim_loc)

  data <- process_type_status(data, type_vars, select)

  data <- combine_fields(data, combine)

  media <- process_media(data, media_vars)

  data[names(media_vars)] <- NULL

  data <- list(occurrence = data, media = NULL)

  if (nrow(media) > 0L) {

    data[["media"]] <- media

  }

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
#' @importFrom wk wk_meta wkt xy_x xy_y

process_points <- function(data) {

  nms <- names(data)

  has_fp <- "footprintWKT" %in% nms

  has_lon <- "decimalLongitude" %in% nms

  has_lat <- "decimalLatitude" %in% nms

  has_coords <- has_lon || has_lat

  process <- has_fp && has_coords

  if (process) {

    footprint <- data[["footprintWKT"]]

    footprint <- wk::wkt(footprint)

    is_point <- wk::wk_meta(footprint)

    is_point <- is_point[["geometry_type"]]

    is_point <- !is.na(is_point) & is_point == 1L

    footprint <- footprint[is_point]

    if (has_lon) {

      x <- wk::xy_x(footprint)

      data[is_point, "decimalLongitude"] <- x

    }

    if (has_lat) {

      y <- wk::xy_y(footprint)

      data[is_point, "decimalLatitude"] <- y

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

process_facts <- function(data, facts) {

  for (i in names(facts)) {

    data[[i]] <- vapply(data[[i]], pipe_collapse, "")

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

process_occurrence_remarks <- function(data, oq, dk, rk) {

  if (!is.null(oq)) {

    or <- "occurrenceRemarks"

    data[[or]] <- ifelse(is.na(data[[or]]), "", paste0("\n", data[[or]]))

    kw <- mapply(c, data[[dk]], data[[rk]], SIMPLIFY = FALSE)

    kw <- vapply(kw, pipe_collapse, "")

    kw <- ifelse(kw == "", kw, paste0("\nKeywords: { ", kw, " }"))

    data[[or]] <- paste0(kw, data[[or]])

    data[[or]] <- paste0(
      "Quality assessment: ",
      ifelse(is.na(data[[oq]]), "Unassessed", data[[oq]]),
      data[[or]]
    )

    data[[oq]] <- NULL
    data[[dk]] <- NULL
    data[[rk]] <- NULL

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

combine_fields <- function(data, combine) {

  for (i in names(combine)) {

    cols <- data[combine[[i]], drop = FALSE]

    data[combine[[i]]] <- NULL

    data[[i]] <- apply(cols, 1L, pipe_collapse)

  }

  data

}

#' @noRd
#' @importFrom tidyr unnest
#' @importFrom rlang .data

process_media <- function(data, media_vars) {

  media_data <- data.frame()

  has_media <- all(names(media_vars) %in% names(data))

  if (has_media) {

    media_data <- data[names(media_vars)]

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

  }

  media_data

}

#' @noRd
#' @importFrom stats na.omit

paste_type_status <- function(
  typeStatus,
  typeSpecimenStatus,
  typeSpecimenTaxon,
  typeSpecimenAuthor
) {

  ans <- ""

  if (typeStatus) {

    typeSpecimenStatus <- stats::na.omit(typeSpecimenStatus)
    typeSpecimenStatus <- types[typeSpecimenStatus]

    typeSpecimenTaxon <- stats::na.omit(typeSpecimenTaxon)

    typeSpecimenAuthor <- stats::na.omit(typeSpecimenAuthor)

    ans <- paste(
      typeSpecimenStatus, typeSpecimenTaxon, typeSpecimenAuthor
    )

    ans <- paste(ans, collapse = " | ")

    ans <- gsub("\\s+", " ", ans)

    ans <- gsub("^ *-|- *$", "", ans)

    ans <- trimws(ans)

  }

  ans

}

#' @noRd
#' @importFrom stats na.omit
#'
pipe_collapse <- function(x) {

  x <- stats::na.omit(x)

  ans <- ""

  if (length(x) > 0L) {

    ans <- paste(x, collapse = " | ")

  }

  ans

}
