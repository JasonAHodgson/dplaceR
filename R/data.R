#' Societies in D-PLACE
#'
#' One row per society (or, for a small number of rows, "languoid" --
#' a language variety referenced only by a phylogeny, with no coded
#' cultural data of its own).
#'
#' @format A tibble with one row per society and the following columns:
#' \describe{
#'   \item{soc_id}{Character. D-PLACE society identifier, e.g. `"B72"`.
#'     Used to join to [dplace_values].}
#'   \item{name}{Character. Society name.}
#'   \item{latitude, longitude}{Numeric. Approximate coordinates.}
#'   \item{glottocode}{Character. Glottolog language code for this society,
#'     where known. Used to link to language phylogenies.}
#'   \item{iso_code}{Character. ISO 639-3 code, where known.}
#'   \item{region}{Character. World region.}
#'   \item{type}{Character. `"society"` (has coded cultural data) or
#'     `"languoid"` (reference node in a phylogeny only).}
#'   \item{main_focal_year}{Integer. Approximate year the ethnographic
#'     description refers to.}
#'   \item{language_level_glottocodes}{Character. Glottocode(s) at the
#'     language level associated with this society.}
#'   \item{contribution_id}{Character. Identifies the source dataset; joins
#'     to [dplace_contributions].}
#'   \item{xd_id}{Character. Cross-dataset identifier, `NA` for most
#'     societies. Societies from different datasets that independently code
#'     the same real-world group share an `xd_id` -- e.g. the !Kung are
#'     coded separately by Binford, the Ethnographic Atlas, and the SCCS,
#'     and all three share `xd_id = "xd1"`. See [get_related_societies()].}
#' }
#' @source D-PLACE CLDF dataset, \url{https://github.com/D-PLACE/dplace-cldf}.
#'   See [dplace_meta] for the exact release bundled with this package.
#' @seealso [dp_societies()], [get_related_societies()]
"dplace_societies"

#' Cultural and environmental variables in D-PLACE
#'
#' One row per variable that can be coded for a society (e.g. subsistence
#' strategy, descent system, settlement pattern).
#'
#' @format A tibble with one row per variable and the following columns:
#' \describe{
#'   \item{var_id}{Character. D-PLACE variable identifier, e.g. `"EA202"`.
#'     Used to join to [dplace_values] and [dplace_codes].}
#'   \item{name}{Character. Short variable name.}
#'   \item{description}{Character. Longer description of what the variable
#'     measures.}
#'   \item{category}{Character. Broad topic, e.g. `"Subsistence"`,
#'     `"Kinship"`, `"Warfare"`.}
#'   \item{type}{Character. `"Categorical"`, `"Ordinal"`, or
#'     `"Continuous"`.}
#'   \item{unit}{Character. Unit of measurement, for continuous variables.}
#'   \item{contribution_id}{Character. Identifies the source dataset; joins
#'     to [dplace_contributions].}
#' }
#' @source D-PLACE CLDF dataset, \url{https://github.com/D-PLACE/dplace-cldf}.
#'   See [dplace_meta] for the exact release bundled with this package.
#' @seealso [dp_variables()], [dp_search_variables()]
"dplace_variables"

#' Codes for categorical/ordinal D-PLACE variables
#'
#' One row per possible code (category) for a categorical or ordinal
#' variable in [dplace_variables].
#'
#' @format A tibble with one row per code and the following columns:
#' \describe{
#'   \item{code_id}{Character. Identifier used in [dplace_values]$code_id.}
#'   \item{var_id}{Character. The variable this code belongs to; joins to
#'     [dplace_variables].}
#'   \item{name}{Character. Short label for this code.}
#'   \item{description}{Character. Longer description.}
#'   \item{ord}{Integer. Rank order, for ordinal variables.}
#' }
#' @source D-PLACE CLDF dataset, \url{https://github.com/D-PLACE/dplace-cldf}.
#'   See [dplace_meta] for the exact release bundled with this package.
#' @seealso [dp_codes()]
"dplace_codes"

#' Coded values linking societies to variables
#'
#' The core "long format" data table of D-PLACE: one row per
#' society/variable measurement.
#'
#' @format A tibble with the following columns:
#' \describe{
#'   \item{id}{Character. Unique row identifier.}
#'   \item{soc_id}{Character. Society identifier; joins to
#'     [dplace_societies].}
#'   \item{var_id}{Character. Variable identifier; joins to
#'     [dplace_variables].}
#'   \item{value}{Character. The raw coded value: for categorical/ordinal
#'     variables this is a code, for continuous variables a number stored
#'     as text.}
#'   \item{code_id}{Character. For categorical/ordinal variables, joins to
#'     [dplace_codes]; `NA` for continuous variables.}
#'   \item{year}{Integer. Year associated with this observation, where
#'     given.}
#'   \item{source}{Character. Semicolon-separated citation key(s) for the
#'     original source(s) of this observation.}
#'   \item{admin_comment}{Character. Curatorial comment, where present.}
#' }
#' @source D-PLACE CLDF dataset, \url{https://github.com/D-PLACE/dplace-cldf}.
#'   See [dplace_meta] for the exact release bundled with this package.
#' @seealso [dp_values()], [dp_variable_data()]
"dplace_values"

#' D-PLACE dataset contributions (sources)
#'
#' One row per source dataset or phylogeny contributed to D-PLACE (e.g. the
#' Binford hunter-gatherer dataset, the Ethnographic Atlas).
#'
#' @format A tibble with the following columns:
#' \describe{
#'   \item{contribution_id}{Character. Joins to `contribution_id` in
#'     [dplace_societies], [dplace_variables], and [dplace_trees].}
#'   \item{name}{Character. Dataset name.}
#'   \item{description}{Character. Description of the dataset.}
#'   \item{contributor}{Character. Who contributed/compiled it.}
#'   \item{citation}{Character. Suggested citation.}
#'   \item{doi}{Character. DOI, where available.}
#'   \item{type}{Character. e.g. `"dataset"` or `"phylogeny"`.}
#' }
#' @source D-PLACE CLDF dataset, \url{https://github.com/D-PLACE/dplace-cldf}.
#'   See [dplace_meta] for the exact release bundled with this package.
#' @seealso [dp_contributions()]
"dplace_contributions"

#' Language phylogenies in D-PLACE
#'
#' One row per phylogenetic/classification tree available in D-PLACE, with
#' the tree itself stored as raw NEXUS text.
#'
#' @format A tibble with the following columns:
#' \describe{
#'   \item{tree_id}{Character. Usually a Glottocode identifying the
#'     language family/group the tree covers.}
#'   \item{name}{Character. Tree name (often `"summary"`).}
#'   \item{is_rooted}{Character. `"Yes"`/`"No"`.}
#'   \item{tree_type}{Character. e.g. `"summary"`.}
#'   \item{branch_length_unit}{Character. Unit for branch lengths, if any.}
#'   \item{source}{Character. Where the tree comes from, e.g.
#'     `"glottolog_glottolog"` or `"dplace-phylogeny-atkinson2006"`.}
#'   \item{contribution_id}{Character. For trees with `source` other than
#'     `"glottolog_glottolog"`, joins to [dplace_contributions]. For plain
#'     Glottolog classification trees (`source == "glottolog_glottolog"`)
#'     D-PLACE has no separate contribution record, so this repeats the
#'     tree's Glottocode instead and will not match a row in
#'     [dplace_contributions].}
#'   \item{nexus}{Character. The full tree in NEXUS format. Use
#'     [dp_tree()] to parse this into an `ape::phylo` object.}
#' }
#' @source D-PLACE CLDF dataset, \url{https://github.com/D-PLACE/dplace-cldf}.
#'   See [dplace_meta] for the exact release bundled with this package.
#' @seealso [dp_trees()], [dp_tree()]
"dplace_trees"

#' Metadata about the bundled D-PLACE snapshot
#'
#' A one-row tibble describing exactly which D-PLACE CLDF release is bundled
#' with this version of dplaceR, when it was prepared, and how to cite it.
#'
#' @format A tibble with columns `cldf_version`, `source_repo`,
#'   `prepared_on`, `citation`, and `data_license`.
#' @seealso [dp_citation()]
"dplace_meta"
