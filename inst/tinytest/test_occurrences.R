source("setup.R")

archive <- structure("archive.zip", class = "archive_file")

expect_equal(write_meta(archive, list(), "occurrenceID"), 0L)

filter <- list(collection = "HR.139")

attr(filter, "n") <- 10L

attr(filter, "collection_id") <- "HR.139"

expect_equal(
  archive_occurrences(
    archive,
    "occurrence_test.txt",
    "media_test.txt",
    filter,
    c(
      "occurrenceID", "basisOfRecord", "associatedMedia",
      "recordedBy", "occurrenceRemarks", "typeStatus", "country"
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

expect_equal(n_archived_subsets("stage/archive.zip"), 1L)

expect_true(unstage_archive("stage/archive.zip", "."))

expect_true(publish_archive("split/archive.zip", "."))

expect_equal(clean_occurrences(archive, get_subsets("HR.139", NULL)), 0L)

expect_equal(count_occurrences(archive, "occurrence_test.txt"), 0L)

expect_inherits(last_mod(archive, "occurrence_test.txt"), "POSIXct")

unlink("archive.zip")

filter <- list(list(collection = "HR.85", has_record_media = TRUE))

write_meta(archive, filter)

expect_equal(
  archive_occurrences(
    archive, "occurrence_16d6d944.txt", "media_16d6d944.txt", filter, n = 136L
  ),
  0L
)

expect_equal(write_meta(archive, filter), 0L)
