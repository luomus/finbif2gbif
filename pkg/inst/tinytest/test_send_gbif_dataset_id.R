gbif <- webfakes::new_app()

gbif$post(
  "/v1/dataset/1234/identifier",
  function(req, res) {
    res$set_status(201L)$send("")
  }
)

api <- webfakes::local_app_process(gbif)

expect_identical(
  send_gbif_dataset_id(list(), "1234", api$url()), NULL
)

api$stop()
