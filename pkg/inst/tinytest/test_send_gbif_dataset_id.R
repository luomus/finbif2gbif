gbif <- webfakes::new_app()

gbif$post(
  "/v1/dataset/abcd/identifier",
  function(req, res) {
    res$set_status(201L)$send("")
  }
)

api <- webfakes::local_app_process(gbif)

expect_identical(
  send_gbif_dataset_id(structure("1234", class = "col_id"), "abcd", api$url()),
  NULL
)

api$stop()
