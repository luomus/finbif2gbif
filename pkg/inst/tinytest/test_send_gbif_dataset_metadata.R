gbif <- webfakes::new_app()

gbif$post(
  "/v1/dataset",
  function(req, res) {
    res$send_json("uuid")
  }
)

api <- webfakes::local_app_process(gbif)

expect_identical(send_gbif_dataset_metadata(list(), api$url()), list("uuid"))

api$stop()
