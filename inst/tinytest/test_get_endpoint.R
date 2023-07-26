Sys.setenv(ENDPOINTS = "https://finbif-archives.fi")

expect_identical(
  get_endpoint("HR.139"),
  list(
    list(
      type = "DWC_ARCHIVE",
      url = "https://finbif-archives.fi/archives/HR.139.zip"
    ),
    list(
      type = "EML",
      url = "https://finbif-archives.fi/eml/HR.139.zip"
    )
  )
)