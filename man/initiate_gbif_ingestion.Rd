% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/initiate_gbif_ingestion.R
\name{initiate_gbif_ingestion}
\alias{initiate_gbif_ingestion}
\title{Initiate ingestion}
\usage{
initiate_gbif_ingestion(
  uuid,
  url = Sys.getenv("GBIF_API"),
  user = Sys.getenv("GBIF_USER"),
  pass = Sys.getenv("GBIF_PASS")
)
}
\arguments{
\item{uuid}{Integer. GBIF registration id.}

\item{url}{Character. URL of GBIF API. Defaults to system environment
variable, "GBIF_API".}

\item{user}{Character. GBIF username. Defaults to system environment
variable, "GBIF_USER".}

\item{pass}{Character. GBIF password. Defaults to system environment
variable, "GBIF_PASS".}
}
\value{
NULL.
}
\description{
Ingitiate GBIF ingestion of FinBIF data.
}
\examples{
\dontrun{

collection <- get_collection_ids()[[1L]]
registration <- get_registration(get_gbif_datasets(), collection)
initiate_gbif_ingestion(registration)

}
}
