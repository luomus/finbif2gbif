source("setup.R")

expect_inherits(last_mod(c(collection = "HR.139")), "Date")
