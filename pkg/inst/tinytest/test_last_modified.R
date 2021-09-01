Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(finbif_allow_query = FALSE, finbif_cache_path = getwd())

last_mod <- last_modified(c(collection = "HR.3991"))

expect_inherits(last_mod, "Date")
