suppressPackageStartupMessages({

  library(f2g, quietly = TRUE)
  library(finbif, quietly = TRUE)
  library(tictoc, quietly = TRUE)

})

options(
  finbif_api_url = Sys.getenv("FINBIF_API"),
  finbif_use_cache = c(FALSE, TRUE),
  finbif_use_cache_metadata = TRUE,
  finbif_max_page_size = 250L,
  finbif_rate_limit = Inf,
  finbif_retry_times = 10,
  finbif_retry_pause_base = 2,
  finbif_retry_pause_cap = 5e3
)

source("update_collection.R")

gbif_datasets <- get_gbif_datasets()

finbif_collections <- get_collection_ids(gbif_datasets)

for (collection in sample(finbif_collections)) {

  Sys.setenv(R_CONFIG_ACTIVE = collection)

  timeout <- 3600 * config::get("timeout")

  if (skip_collection(collection)) next

  update_collection(collection, start_timer, gbif_datasets)

  stop_timer <- toc(quiet = TRUE)

  tic()

  if (stop_timer$toc - start_timer > timeout) {

    message(
      sprintf(
        "INFO [%s] Reached time limit. Job exiting", format(Sys.time())
      )
    )

    break

  }

}

message(sprintf("INFO [%s] Job complete", format(Sys.time())))
