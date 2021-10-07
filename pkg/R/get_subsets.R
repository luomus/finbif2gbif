#' Get subsets
#'
#' Get subset filters for a collection.
#'
#' @param collection_id Character. ID string of FinBIF collection.
#' @param subsets List.
#'
#' @return A list.
#' @examples \dontrun{
#'
#' get_subsets("HR.3991")
#'
#' }
#' @export

get_subsets <- function(
  collection_id,
  subsets = config::get("subsets")
) {

   if (is.null(subsets)) {

     subsets <- list(NULL)

   }

  collection <- c(collection = collection_id)

  for (subset in seq(subsets)) {

    subsets[[subset]] <- c(collection, subsets[[subset]])
  }

  subsets

}
