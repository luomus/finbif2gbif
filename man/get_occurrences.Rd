% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_occurrences.R
\name{get_occurrences}
\alias{get_occurrences}
\title{Get occurrences}
\usage{
get_occurrences(filter, select, facts, combine, n, quiet = TRUE)
}
\arguments{
\item{filter}{List of named character vectors. Filters to apply to records.}

\item{select}{Character vector. Variables to return. If not specified, a
default set of commonly used variables will be used. Use \code{"default_vars"}
as a shortcut for this set. Variables can be deselected by prepending a \code{-}
to the variable name. If only deselects are specified the default set of
variables without the deselection will be returned.}

\item{facts}{List of extra variables to be extracted from record,
event and document "facts".}

\item{combine}{List of fields to combine.}

\item{n}{Integer. How many records to download/import.}

\item{quiet}{Logical. Suppress the progress indicator for multipage
downloads.}
}
\value{
A finbif_occ object.
}
\description{
Get occurrence records from FinBIF.
}
\examples{
\dontrun{

get_occurrences(
  c(collection = "HR.3991"), c("occurrenceID", "basisOfRecord"), 100
)

}
}
