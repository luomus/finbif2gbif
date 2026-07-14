Sys.setenv(ENDPOINTS = "https://finbif-archives.fi")

expect_identical(
  get_endpoint("HR.139"),
  list(
    list(
      type = "DWC_ARCHIVE",
      url = "https://finbif-archives.fi/archive/HR.139"
    ),
    list(
      type = "EML",
      url = "https://finbif-archives.fi/metadata/HR.139"
    )
  )
)