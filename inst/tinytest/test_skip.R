source("setup.R")

expect_true(skip_collection("HR.22", FALSE))

expect_false(skip_collection("HR.22", TRUE))

expect_true(skip_gbif("HR.22", FALSE))

expect_false(skip_gbif("HR.22", TRUE))
