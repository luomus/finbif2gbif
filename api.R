#* @apiTitle FinBIF - GBIF data endpoints
#* @apiTOS https://laji.fi/en/about/845
#* @apiContact list(name = "laji.fi support", email = "helpdesk@laji.fi")
#* @apiLicense list(name = "GPL-2.0", url = "https://opensource.org/licenses/GPL-2.0")
#* @apiTag list List archives
#* @apiTag info Get info for an archive
#* @apiTag status Check status of API

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

 list.files("archives", pattern = "\\.zip$")

}

#* Get the last modified time for a Darwin Core archive
#* @get /lastmod
#* @param archive:str Collection ID of archive to check the last modified time for.
#* @tag info
#* @response 200 A json object
#* @serializer unboxedJSON
function(archive, res) {

  path <- sprintf("archives/%s.zip", archive)

  if (!file.exists(path)) {

    res$status <- 404L
    return("File not found")

  }

  ans <- file.mtime(path)

  format(ans)

}

#* @assets ./logs/status /status
list()

#* @assets ./archives/combined /archives
list()

#* @assets /usr/local/lib/R/library/finbif/help/figures
list()

#* @get /favicon.ico
#* @serializer contentType list(type="image/x-icon")
function() {

  readBin("favicon.ico", "raw", n = file.info("favicon.ico")$size)

}

#* @plumber
function(pr) {

  version <- as.character(utils::packageVersion("f2g"))

  plumber::pr_set_api_spec(
    pr,
    function(spec) {

      spec$info$version <- version

      spec$paths$`/healthz` <- NULL
      spec$paths$`/favicon.ico` <- NULL

      spec

    }
  )

  pr$setDocs(
    "rapidoc",
    bg_color = "#2691d9",
    text_color = "#ffffff",
    primary_color = "#2c3e50",
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
