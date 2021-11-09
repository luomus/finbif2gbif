Sys.setenv(FINBIF_ACCESS_TOKEN = "dummy")

options(
  finbif_api_url = "https://apitest.laji.fi",
  finbif_allow_query = FALSE,
  finbif_use_cache = TRUE,
  finbif_cache_path = getwd(),
  finbif_max_page_size = 250L
)

utils::assignInNamespace("var_names", finbif:::var_names_test, "finbif")
utils::assignInNamespace("filter_names", finbif:::filter_names_test, "finbif")
