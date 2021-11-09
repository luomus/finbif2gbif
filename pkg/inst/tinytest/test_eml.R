source("setup.R")

archive <- structure("archive.zip", class = "archive_file")

col <- "HR.3491"

md <- get_metadata(
  col,
  list(
    title = "long_name",
    description = "description",
    license = "intellectual_rights"
  )
)

res <- write_eml(
  archive,
  col,
  "1234",
  md,
  list(
    dataLanguage = "language",
    methods = "methods",
    geographicDescription = "geographic_coverage",
    contact = "person_responsible",
    email = "contact_email"
  )
)

expect_equal(res, 0L)
