#* @apiTitle FinBIF - GBIF data endpoints
#* @apiTOS https://laji.fi/en/about/845
#* @apiContact list(name = "laji.fi support", email = "helpdesk@laji.fi")
#* @apiLicense list(name = "MIT", url = "https://opensource.org/licenses/MIT")
#* @apiTag list List archives
#* @apiTag info Get info for an archive
#* @apiTag status Check status of API

suppressPackageStartupMessages({

  library(finbif, quietly = TRUE)
  library(f2g, quietly = TRUE)
  library(lubridate, quietly = TRUE)
  library(rapidoc, quietly = TRUE)
  library(utils, quietly = TRUE)
  library(callr, quietly = TRUE)

})

options(
  finbif_api_url = Sys.getenv("FINBIF_API"),
  finbif_use_cache = FALSE,
  finbif_max_page_size = 250L,
  finbif_rate_limit = 10L,
  finbif_retry_times = 10,
  finbif_retry_pause_base = 2,
  finbif_retry_pause_cap = 5e3
)

#* @filter cors
cors <- function(req, res) {

  res$setHeader("Access-Control-Allow-Origin", "*")

  if (identical(req$REQUEST_METHOD, "OPTIONS")) {

    res$setHeader("Access-Control-Allow-Methods", "*")
    res$setHeader(
      "Access-Control-Allow-Headers",
      req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS
    )

    res$status <- 200L

    list()

  } else {

    plumber::forward()

  }

}

#* @filter secret
function(req, res) {

  secret <- identical(req[["argsQuery"]][["secret"]], Sys.getenv("JOB_SECRET"))

  if (grepl("job", req[["PATH_INFO"]]) && !secret) {

    res[["status"]] <- 401
    list(error = "Access token required")

  } else {

    forward()

  }

}

#* @get /job
#* @serializer unboxedJSON
function() {

  callr::r_bg(
    source,
    args = list(file = "../finbif2gbif.R"),
    poll_connection = FALSE,
    cleanup = FALSE,
    wd = "var"
  )

  "success"

}

#* Check the liveness of the API
#* @head /healthz
#* @get /healthz
#* @tag status
#* @response 200 A json object
#* @serializer unboxedJSON
function() {
 ""
}

#* Get a list of Darwin Core archives
#* @get /list
#* @tag list
#* @response 200 A json object
#* @serializer unboxedJSON
function() {

 list.files("var/archives/combined", pattern = "\\.zip$")

}

#* Get the last modified time for a Darwin Core archive
#* @get /lastmod
#* @param archive:str Archive to check.
#* @tag info
#* @response 200 A json object
#* @serializer unboxedJSON
function(archive, res) {

  path <- sprintf("var/archives/combined/%s", archive)

  if (!file.exists(path)) {

    res$status <- 404L
    return("File not found")

  }

  ans <- file.mtime(path)

  format_ISO8601(ans, usetz = TRUE)

}

#* Get the EML file from a Darwin Core archive
#* @get /eml/<archive:str>
#* @head /eml/<archive:str>
#* @param archive:str Archive file.
#* @response 200 An xml file attachment
#* @response 404 File not found
#* @serializer contentType list(type="application/xml")
function(archive, res) {

  archive <- paste0("var/archives/combined/", archive)

  if (!file.exists(archive)) {

    res$serializer <- plumber::serializer_unboxed_json()
    res$status <- 404L
    return("Archive not found")

  }

  files <- utils::unzip(archive, list = TRUE)

  file <- "eml.xml"

  if (!any(grepl(file, files[["Name"]]))) {

    res$serializer <- plumber::serializer_unboxed_json()
    res$status <- 404L
    return("EML file not found")

  }

  con <- unz(archive, file, "rb")
  on.exit(close(con))

  eml <- readBin(con, "raw", n = files[files[["Name"]] == file, "Length"])

  plumber::as_attachment(eml, file)

}

#* Get the EML for dataset
#* @get /metadata/<collectionID:str>
#* @head /metadata/<collectionID:str>
#* @param collectionID:str Archive file.
#* @response 200 An xml file
#* @response 404 File not found
#* @serializer contentType list(type="application/xml")
function(collectionID, res) {

  archive <- paste0("var/archives/combined/", collectionID, ".zip")

  if (!file.exists(archive)) {

    res$serializer <- plumber::serializer_unboxed_json()
    res$status <- 404L
    return("Archive not found")

  }

  files <- utils::unzip(archive, list = TRUE)

  file <- "eml.xml"

  if (!any(grepl(file, files[["Name"]]))) {

    res$serializer <- plumber::serializer_unboxed_json()
    res$status <- 404L
    return("EML file not found")

  }

  con <- unz(archive, file, "rb")
  on.exit(close(con))

  readBin(con, "raw", n = files[files[["Name"]] == file, "Length"])
}

#* Get the DwCA for dataset
#* @get /archive/<collectionID:str>
#* @head /archive/<collectionID:str>
#* @param collectionID:str Archive file.
#* @response 200 A zip archive
#* @response 404 File not found
#* @serializer contentType list(type="application/zip")
function(collectionID, res) {

  archive <- paste0("var/archives/combined/", collectionID, ".zip")

  if (!file.exists(archive)) {

    res$serializer <- plumber::serializer_unboxed_json()
    res$status <- 404L
    return("Archive not found")

  }

  readBin(archive, "raw", n = file.info(archive)$size)

}

#* @assets ./var/logs /logs
list()

#* @assets ./var/status /status
list()

#* @assets ./var/archives/combined /archives
list()

#* @assets /usr/local/lib/R/site-library/finbif/help/figures
list()

#* @get /favicon.ico
#* @serializer contentType list(type="image/x-icon")
function() {

  readBin("favicon.ico", "raw", n = file.info("favicon.ico")$size)

}

#* @get /robots.txt
#* @serializer contentType list(type="text/plain")
function() {

  readBin("robots.txt", "raw", n = file.info("robots.txt")$size)

}

#* @get /
function(res) {

  res$status <- 303L
  res$setHeader("Location", "/__docs__/")

}

#* @plumber
function(pr) {

  version <- as.character(utils::packageVersion("f2g"))

  plumber::pr_set_api_spec(
    pr,
    function(spec) {

      spec$info$version <- version

      spec$paths$`/job` <- NULL
      spec$paths$`/healthz` <- NULL
      spec$paths$`/favicon.ico` <- NULL
      spec$paths$`/robots.txt` <- NULL
      spec$paths$`/` <- NULL
      spec$paths$`/eml/{archive}`$head <- NULL
      spec$paths$`/eml/{archive}`$get <- NULL
      spec$paths$`/metadata/{collectionID}`$head <- NULL
      spec$paths$`/archive/{collectionID}`$head <- NULL

      spec

    }
  )

  pr$setDocs(
    "rapidoc",
    bg_color ="#141B15",
    text_color = "#FFFFFF",
    primary_color = "#55AAE2",
    render_style = "read",
    slots = paste0(
      '<img ',
      'slot="logo" ',
      'src="../public/logo.png" ',
      'width=36px style=\"margin-left:7px\"/>'
    ),
    heading_text = paste("F2G", version),
    regular_font = "Roboto, Helvetica Neue, Helvetica, Arial, sans-serif",
    font_size = "largest",
    sort_tags = "false",
    sort_endpoints_by = "summary",
    allow_spec_file_load = "false"
  )

}
