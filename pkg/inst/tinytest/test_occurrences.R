source("setup.R")

archive <- structure("archive.zip", class = "archive_file")

expect_equal(write_meta(archive, list(), "occurrenceID"), 0L)

expect_equal(
  archive_occurrences(
    archive,
    "occurrence_test.txt",
    list(collection = "HR.139"),
    c(
      "occurrenceID", "basisOfRecord", "associatedMedia", "license",
      "recordedBy"
    ),
    10L,
  ),
  0L
)

expect_equal(count_occurrences(archive, "occurrence_test.txt"), 10L)

Sys.setenv(R_CONFIG_ACTIVE = "test")

dir.create("stage")

expect_equal(
  stage_archive(archive),
  structure("stage/archive.zip", class = "archive_file")
)

dir.create("split")
dir.create("combined")

expect_equal(publish_archive("stage/archive.zip", "."), 0L)

expect_equal(clean_occurrences(archive, get_subsets("HR.139", NULL)), 0L)

expect_equal(count_occurrences(archive, "occurrence_test.txt"), 0L)

expect_inherits(last_mod(archive, "occurrence_test.txt"), "POSIXct")
