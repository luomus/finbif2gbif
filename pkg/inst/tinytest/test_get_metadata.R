options("finbif_allow_query" = FALSE, "finbif_cache_path" = getwd())

expect_inherits(get_metadata("HR.3991"), "list")