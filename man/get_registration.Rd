% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_registration.R
\name{get_registration}
\alias{get_registration}
\title{Check registration}
\usage{
get_registration(datasets, collection_id, quiet = FALSE)
}
\arguments{
\item{datasets}{List. GBIF dataset metadata retrieved using \code{gbif_datasets}.}

\item{collection_id}{Character. ID string of FinBIF collection.}

\item{quiet}{Logical. Suppress messages.}
}
\value{
Integer.
}
\description{
Check if a FinBIF collection is registered with GBIF.
}
\examples{
\dontrun{

get_registration(gbif_datasets(), "HR.3991")

}
}
