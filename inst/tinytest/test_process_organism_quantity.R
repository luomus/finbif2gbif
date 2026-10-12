expect_equal(
  f2g:::process_organism_quantity(
    list(
      organismQuantity = c(1L, 1L),
      organismQuantityType = c("individuals", NA_character_)
    )
  ),
  list(
    organismQuantity = c(1L, 1L),
    organismQuantityType = c("individuals", "individuals")
  )
)
