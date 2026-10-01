expect_equal(
  f2g:::process_day(
    list(
      day = c(1L, 1L),
      eventDate = c("1980-01-01", "1980-01-01/02"),
      startDayOfYear = c(1L, 1L),
      endDayOfYear = c(1L, 2L)
    )
  ),
  list(
    day = c(1L, NA_integer_),
    eventDate = c("1980-01-01", "1980-01-01/02"),
    startDayOfYear = c(1L, 1L),
    endDayOfYear = c(NA_integer_, 2L)
  )
)
