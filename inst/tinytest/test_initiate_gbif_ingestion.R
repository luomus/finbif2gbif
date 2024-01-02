gbif <- webfakes::new_app()

gbif$post(
  "/v1/dataset/1234/crawl",
  function(req, res) {
    res$set_status(204L)$send("")
  }
)

api <- webfakes::local_app_process(gbif)

expect_identical(
  initiate_gbif_ingestion("1234", api$url()),
  NULL
)

api$stop()
