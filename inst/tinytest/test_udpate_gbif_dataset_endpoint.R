gbif <- webfakes::new_app()

gbif$post(
  "/v1/dataset/1234/endpoint",
  function(req, res) {
    res$set_status(201L)$send("")
  }
)

gbif$get(
  "/v1/dataset/1234/endpoint",
  function(req, res) {
    file <- "endpoints"
    ans <- readBin(file, "raw", n = file.info(file)$size)
    res$send(ans)
  }
)

gbif$delete(
  "/v1/dataset/1234/endpoint/480011",
  function(req, res) {
    res$set_status(204L)$send("")
  }
)

gbif$delete(
  "/v1/dataset/1234/endpoint/480010",
  function(req, res) {
    res$set_status(204L)$send("")
  }
)

api <- webfakes::local_app_process(gbif)

expect_identical(
  update_gbif_dataset_endpoint(
    list(list(url = "test")), "1234", api$url()
  ),
  NULL
)

api$stop()
