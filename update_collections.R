suppressPackageStartupMessages({

  library(f2g, quietly = TRUE)
  library(finbif, quietly = TRUE)
  library(tictoc, quietly = TRUE)

})

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
