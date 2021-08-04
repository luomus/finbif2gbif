Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options("finbif_allow_query" = FALSE, "finbif_cache_path" = getwd())

occurrences <- get_occurrences(c(collection = "HR.3991"), "occurrenceID", 10)

expect_inherits(occurrences, "finbif_occ")

expect_equal(write_occurrences(occurrences, tempfile()), 0L)
