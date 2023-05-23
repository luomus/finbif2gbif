source("setup.R")

expect_true(skip_collection("HR.139", FALSE))

expect_false(skip_collection("HR.139", TRUE))

expect_true(skip_gbif("HR.139", FALSE))

expect_false(skip_gbif("HR.139", TRUE))
