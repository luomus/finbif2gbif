Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(
  finbif_api_url = "https://apitest.laji.fi",
  finbif_allow_query = FALSE,
  finbif_cache_path = getwd()
)

collections <- get_collection_ids()

expect_inherits(collections, "list")

expect_inherits(last_mod(collections[[1L]]), "Date")
