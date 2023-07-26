source("setup.R")

expect_inherits(last_mod(c(collection = "HR.139")), "Date")

expect_inherits(last_mod(c(collection = "HR.1027")), "Date")
