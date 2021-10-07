x <- 1L
attr(x, "class") <- "registration"
attr(x, "last_mod") <- as.Date(integer(0L))

expect_equal(
  get_registration(list(list(identifiers = list(list(identifier = "x")))), "x"),
  x
)

expect_null(
  get_registration(list(list(identifiers = list(list(identifier = "x")))), "y"),
)

expect_equal(last_mod(x), as.Date(integer(0L)))
