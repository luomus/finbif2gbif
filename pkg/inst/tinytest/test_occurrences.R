Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(finbif_allow_query = FALSE, finbif_cache_path = getwd())

expect_equal(
  archive_occurrences(
    c(collection = "HR.3991"),
    c("occurrenceID", "basisOfRecord"),
    tempfile()
  ),
  0L
)
