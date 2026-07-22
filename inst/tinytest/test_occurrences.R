source("setup.R")

archive <- structure("archive.zip", class = "archive_file")

gbif <- webfakes::new_app()

gbif$get(
  "/v1/organization/1234",
  function(req, res) {
    res$set_status(200L)$send('{"logo":"test"}')
  }
)

api <- webfakes::local_app_process(gbif)

Sys.setenv(GBIF_API = api$url(), GBIF_ORG = "1234")

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

expect_equal(
  clean_occurrences(
    archive, get_subsets("HR.22", NULL, archive = "archive.zip")
  ),
  0L
)

expect_equal(count_occurrences(archive, "occurrence_test.txt"), 0L)

expect_inherits(last_mod(archive, "occurrence_test.txt"), "POSIXct")

unlink("archive.zip")

filter <- list(list(collection = "HR.203", has_record_images = TRUE))

attr(filter, "collection_id") <- "HR.203"

write_meta(archive, filter)

expect_equal(
  archive_occurrences(
    archive, "occurrence_553732d5.txt", "media_553732d5.txt", filter, n = 21L
  ),
  0L
)

expect_equal(write_meta(archive, filter), 0L)

api$stop()
