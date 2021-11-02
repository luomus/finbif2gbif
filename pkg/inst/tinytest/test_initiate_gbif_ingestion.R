gbif <- webfakes::new_app()

gbif$post(
  "/v1/dataset/1234/crawl",
  function(req, res) {
    res$set_status(204L)$send("")
  }
)

api <- webfakes::local_app_process(gbif)

reg <- 1
attr(reg, "key") <- "1234"
attr(reg, "created") <- format(
  as.POSIXlt(Sys.time(), "UTC"), "%FT%R:%OS+00:00"
)

expect_identical(
  initiate_gbif_ingestion(reg, api$url()),
  NULL
)

api$stop()
