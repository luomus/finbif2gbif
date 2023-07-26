expect_equal(
  f2g:::process_taxon_concept(list(taxonConceptID = list(c("a", "b")))),
  list(taxonConceptID = "a | b")
)
