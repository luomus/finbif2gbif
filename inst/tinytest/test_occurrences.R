source("setup.R")

archive <- structure("archive.zip", class = "archive_file")

expect_equal(
  write_meta(
    archive,
    structure(list(collection = "HR.22"), collection_id = "HR.22"),
    "occurrenceID",
    list(recordNumber = "MY.legID")
  ),
  0L
)

filter <- list(collection = "HR.22", has_media = TRUE)

attr(filter, "n") <- 10L

attr(filter, "collection_id") <- "HR.22"

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
    list(recordNumber = "MY.legID"),
    list(recordNumber = "recordNumber"),
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

expect_equal(clean_occurrences(archive, get_subsets("HR.22", NULL)), 0L)

expect_equal(count_occurrences(archive, "occurrence_test.txt"), 0L)

expect_inherits(last_mod(archive, "occurrence_test.txt"), "POSIXct")

unlink("archive.zip")

filter <- list(list(collection = "HR.22", has_record_media = TRUE))

attr(filter, "collection_id") <- "HR.22"

write_meta(archive, filter)

expect_equal(
  archive_occurrences(
    archive, "occurrence_c651e8eb.txt", "media_c651e8eb.txt", filter, n = 101L
  ),
  0L
)

expect_equal(write_meta(archive, filter), 0L)
