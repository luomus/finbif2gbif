Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(finbif_allow_query = FALSE, finbif_cache_path = getwd())

expect_inherits(get_collection_ids(), "list")
