Sys.setenv(ENDPOINTS = "https://finbif-archives.fi")

expect_identical(
  get_endpoint("HR.139"),
  list(type = "DWC_ARCHIVE", url = "https://finbif-archives.fi/HR.139.zip")
)