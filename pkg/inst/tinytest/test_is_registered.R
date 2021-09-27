x <- 1L
attr(x, "last_mod") <- as.Date(integer(0L))

expect_equal(
  get_registration(list(list(identifiers = list(list(identifier = "x")))), "x"),
  x
)
