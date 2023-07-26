reg <- 1

attr(reg, "key") <- "1234"

expect_equal(get_uuid(reg), "1234")
