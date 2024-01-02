source("setup.R")

gbif <- webfakes::new_app()

gbif$get(
  "/v1/installation/abcd/dataset",
  function(req, res) {
    file <- "gbif_datasets"
    ans <- readBin(file, "raw", n = file.info(file)$size)
    res$send(ans)
  }
)

api <- webfakes::local_app_process(gbif)

datasets <- get_gbif_datasets(api$url(), "abcd")

api$stop()

collections_null <- get_collection_ids(datasets, NULL)

expect_inherits(collections_null, "list")

collections <- get_collection_ids(datasets)

expect_inherits(collections, "list")

expect_inherits(last_mod(collections[[1L]]), "Date")
