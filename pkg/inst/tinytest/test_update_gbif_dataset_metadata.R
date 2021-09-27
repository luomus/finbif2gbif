gbif <- webfakes::new_app()

gbif$put(
  "/v1/dataset/1234",
  function(req, res) {
    res$set_status(204L)$send("")
  }
)

api <- webfakes::local_app_process(gbif)

reg <- 1
attr(reg, "key") <- "1234"
attr(reg, "created") <- format(
  as.POSIXlt(Sys.time(), "Etc/UTC"), "%FT%R:%OS+00:00"
)

expect_identical(
  update_gbif_dataset_metadata(list(), reg, api$url()),
  NULL
)

api$stop()
