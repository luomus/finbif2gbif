Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(
  finbif_api_url = "https://apitest.laji.fi",
  finbif_allow_query = FALSE,
  finbif_cache_path = getwd()
)

expect_equal(write_meta("archive.zip", list(), "occurrenceID"), 0L)

expect_equal(
  archive_occurrences(
    "archive.zip",
    "occurrence.txt",
    list(collection = "HR.139"),
    c("occurrenceID", "basisOfRecord"),
  ),
  0L
)

expect_equal(
  clean_occurrences("archive.zip", get_subsets("HR.139", NULL)),
  0L
)

expect_equal(count_occurrences("archive.zip", "occurrence.txt"), 10L)

Sys.setenv(R_CONFIG_ACTIVE = "test")

expect_equal(clean_occurrences("archive.zip", get_subsets("HR.139", NULL)), 0L)

expect_equal(count_occurrences("archive.zip", "occurrence.txt"), 0L)

expect_inherits(
  last_mod(structure("archive.zip", class = "archive_file"), "occurrence.txt"),
  "POSIXct"
)

expect_equal(get_occurrence_file(1, "x", 1:2), "x_ce606e5a.txt")
