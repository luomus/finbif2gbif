% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/publish_archive.R
\name{publish_archive}
\alias{publish_archive}
\title{Publish archive}
\usage{
publish_archive(staged_archive, dir = "archives")
}
\arguments{
\item{staged_archive}{Character. Path to the staged archive.}

\item{dir}{Character. Path to the archive directory.}
}
\value{
Character. The file path of the staged archive.
}
\description{
Publish a Darwin Core archive.
}
\examples{
\dontrun{

publish_archive("stage/archive.zip")

}
}
