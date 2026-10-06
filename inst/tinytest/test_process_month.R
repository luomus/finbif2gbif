expect_equal(
  f2g:::process_month(
    list(
      month = c(1L, 1L),
      year = c(1980L, NA_integer_),
      eventDate = c("1980-01-01", "1980-01/1981-01")
    )
  ),
  list(
    month = c(1L, NA_integer_),
    year = c(1980L, NA_integer_),
    eventDate = c("1980-01-01", "1980-01/1981-01")
  )
)
