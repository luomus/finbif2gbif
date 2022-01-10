source("setup.R")

expect_inherits(last_mod(c(collection = "HR.139")), "Date")

options(finbif_api_url = "https://api.laji.fi")

expect_inherits(last_mod(c(collection = "HR.3671")), "Date")

options(finbif_api_url = "https://apitest.laji.fi")
