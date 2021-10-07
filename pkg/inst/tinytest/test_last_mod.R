Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(
  finbif_api_url = "https://apitest.laji.fi",
  finbif_allow_query = FALSE,
  finbif_cache_path = getwd()
)

expect_inherits(last_mod(c(collection = "HR.139")), "Date")
