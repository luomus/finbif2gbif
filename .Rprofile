library(finbif)
library(f2g)
library(tictoc)

options(
  finbif_api_url   = Sys.getenv("FINBIF_API"),
  finbif_use_cache = FALSE,
  finbif_max_page_size = 250L,
  finbif_rate_limit = 10L,
  finbif_retry_times = 10,
  finbif_retry_pause_base = 2,
  finbif_retry_pause_cap = 5e3
)

if (identical(getwd(), "/home/user") && !dir.exists("archives/split")) {

  dir.create("archives/split", recursive = TRUE)

}

if (identical(getwd(), "/home/user") && !dir.exists("archives/combined")) {

  dir.create("archives/combined", recursive = TRUE)

}

if (identical(getwd(), "/home/user") && !file.exists("var/config.yml")) {

  invisible(file.copy("config.yml", "var"))

}
