expect_equal(
  f2g:::process_day(
    list(day = c(1L, 1L), eventDate = c("1980-01-01", "1980-01-01/02"))
  ),
  list(day = c(1L, NA_integer_), eventDate = c("1980-01-01", "1980-01-01/02"))
)
