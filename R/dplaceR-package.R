#' dplaceR: An R Interface to the D-PLACE Cross-Cultural Database
#'
#' dplaceR provides convenient access to data from D-PLACE (Database of
#' Places, Language, Culture and Environment, \url{https://d-place.org}), a
#' cross-cultural database linking ethnographic, linguistic, environmental,
#' and geographic information for societies around the world.
#'
#' A snapshot of the D-PLACE CLDF ('Cross-Linguistic Data Format') dataset is
#' bundled with the package (see [dplace_meta] for the exact release used).
#' Because D-PLACE evolves over time, dplaceR intentionally works from a
#' pinned, versioned snapshot rather than a live connection, so that results
#' are reproducible: analyses done with the same dplaceR version will always
#' see the same underlying data.
#'
#' @section Getting started:
#' * [dp_societies()] to browse or filter the societies in D-PLACE
#' * [dp_variables()] / [dp_search_variables()] to find cultural variables
#' * [dp_codes()] to see the possible codes for a categorical/ordinal variable
#' * [dp_variable_data()] to get an analysis-ready table of a variable's
#'   values joined to society information
#' * [dp_trees()] / [dp_tree()] to browse and load language phylogenies
#' * [dp_contributions()] for the source datasets and how to cite them
#'
#' @section Citing D-PLACE:
#' If you use dplaceR in published work, please cite both D-PLACE itself and
#' the specific source dataset(s) your variables come from (see
#' [dp_contributions()] and `dplace_meta$citation`). D-PLACE data is
#' distributed under a CC-BY-NC-4.0 licence; see \url{https://d-place.org}
#' for full citation guidance.
#'
#' @keywords internal
"_PACKAGE"
