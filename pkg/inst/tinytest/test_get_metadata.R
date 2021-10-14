source("setup.R")

expect_inherits(
  get_metadata(
    "HR.139",
    list(
      language = "language",
      license = "intellectual_rights"
    )
  ),
  "list"
)