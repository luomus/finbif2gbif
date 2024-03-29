% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_file_name.R
\name{get_file_name}
\alias{get_file_name}
\title{Get occurrence file name.}
\usage{
get_file_name(filter, select = config::get("fields"), prefix = "occurrence")
}
\arguments{
\item{filter}{List.}

\item{select}{Character.}

\item{prefix}{Character.}
}
\value{
Character. The file name holding occurrence records.
}
\description{
Get the file name of occurrences in an archive
}
\examples{
\dontrun{

get_file_name(list())

}
}
