library(finbif)
library(f2g)
library(future)

plan("multicore", workers = 2L)

options(
  finbif_api_url   = Sys.getenv("FINBIF_API"),
  finbif_use_cache = FALSE
)

if (identical(Sys.getenv("BRANCH"), "dev")) {

  utils::assignInNamespace("var_names", finbif:::var_names_test, "finbif")
  utils::assignInNamespace("filter_names", finbif:::filter_names_test, "finbif")

}
