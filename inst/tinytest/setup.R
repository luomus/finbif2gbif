library(callr, quietly = TRUE)

Sys.setenv(FINBIF_USE_PRIVATE_API = "true")
Sys.setenv(FINBIF_PRIVATE_API = "dev")

options(
  finbif_api_url = "https://apitest.laji.fi",
  finbif_allow_query = FALSE,
  finbif_use_cache = TRUE,
  finbif_cache_path = getwd(),
  finbif_max_page_size = 250L
)
