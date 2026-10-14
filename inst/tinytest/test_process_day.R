expect_equal(
  f2g:::process_day(
    list(
      year = c(1980L, 1980L),
      month = c(1L, 1L),
      day = c(1L, 1L),
      eventDate = c("1980-01-01", "1980-01-01/02"),
      startDayOfYear = c(1L, 1L),
      endDayOfYear = c(1L, 2L)
    )
  ),
  list(
    year = c(1980L, 1980L),
    month = c(1L, 1L),
    day = c(1L, NA_integer_),
    eventDate = c("1980-01-01", "1980-01-01/02"),
    startDayOfYear = c(1L, 1L),
    endDayOfYear = c(1L, 2L)
  )
)
