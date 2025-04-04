source("../update_collection.R")

gbif_datasets <- f2g::get_gbif_datasets()

finbif_collections <- f2g::get_collection_ids(gbif_datasets)

start_timer <- tictoc::tic()

for (collection in sample(finbif_collections)) {

  Sys.setenv(R_CONFIG_ACTIVE = collection)

  timeout <- 3600 * config::get("timeout")

  if (f2g::skip_collection(collection)) next

  update_collection(collection, timeout, start_timer, gbif_datasets)

  stop_timer <- tictoc::toc(quiet = TRUE)

  tictoc::tic()

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
