library(finbif)
library(f2g)
library(tictoc)

options(
  finbif_api_url   = Sys.getenv("FINBIF_API"),
  finbif_use_cache = FALSE,
  finbif_max_page_size = 250L,
  finbif_rate_limit = 10L
)

if (identical(Sys.getenv("BRANCH"), "dev")) {

  utils::assignInNamespace("var_names", finbif:::var_names_test, "finbif")
  utils::assignInNamespace("filter_names", finbif:::filter_names_test, "finbif")

}

if (identical(getwd(), "/home/user") && !dir.exists("archives/split")) {

  dir.create("archives/split", recursive = TRUE)

}

if (identical(getwd(), "/home/user") && !dir.exists("archives/combined")) {

  dir.create("archives/combined", recursive = TRUE)

}

if (identical(getwd(), "/home/user") && !file.exists("var/config.yml")) {

  invisible(file.copy("config.yml", "var"))

}
