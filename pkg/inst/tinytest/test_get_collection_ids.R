source("setup.R")

collections <- get_collection_ids()

expect_inherits(collections, "list")

expect_inherits(last_mod(collections[[1L]]), "Date")
