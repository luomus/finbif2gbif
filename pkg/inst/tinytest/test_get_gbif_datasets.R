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

expect_inherits(get_gbif_datasets(api$url(), "abcd"), "list")

api$stop()
