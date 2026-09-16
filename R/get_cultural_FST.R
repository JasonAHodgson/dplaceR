#' Cultural differentiation (Fst-style) between groups of societies
#'
#' Computes cultural differentiation between GROUPS of societies -- not
#' individual societies, see `group` -- for one or more cultural variables,
#' using measures directly analogous to population-genetic Fst: Nei's Gst
#' for categorical (and, by default, ordinal) variables, and a
#' variance-ratio Qst for continuous variables (and ordinal variables when
#' `type_aware = TRUE`). Both measure what proportion of a variable's total
#' diversity/variance across all the groups is attributable to differences
#' BETWEEN groups rather than variation WITHIN them: `0` means the groups
#' are, on average, indistinguishable on that variable; `1` means every
#' group is internally uniform and no state/value is shared between groups.
#'
#' Unlike [get_cult_distance()]/[get_pairwise_cult_distance()], which
#' compare individual societies, Fst/Qst require a within-group variance
#' term and so are only meaningful between groups of societies -- see
#' `group`. For differentiation between every pair of groups, rather than
#' one combined calculation across all of them at once, use
#' [get_pairwise_cultural_FST()].
#'
#' @details
#' # Groups (`group`)
#' `group` assigns every society in `soc_id` to a group, and is one of:
#' \describe{
#'   \item{`"region"`, `"lang_family"`, or `"lang_family_id"`}{Use one of
#'     D-PLACE's/Glottolog's own built-in groupings directly (see
#'     [dp_societies()]).}
#'   \item{A named character vector}{Names are society IDs, values are group
#'     labels -- robust to `soc_id`'s order.}
#'   \item{An unnamed vector the same length as `soc_id`}{Assigned by
#'     position.}
#' }
#' Societies with an unknown/`NA` group are dropped (with a warning). At
#' least two groups, each with at least one remaining society, are required.
#'
#' # Categorical/ordinal variables: Gst
#' For each variable, treats each group's distribution of coded states like
#' a subpopulation's allele frequencies (Nei, 1973): `Ht` is the "gene
#' diversity" (`1 - sum(p_i^2)`) of the pooled state frequencies across all
#' groups; `Hs` is the sample-size-weighted average of each group's own
#' diversity. `Gst = (Ht - Hs) / Ht`. Ordinal variables are treated this way
#' by default (their `ord` ranking is not used) unless `type_aware = TRUE`
#' -- matching [get_cult_distance()]'s caution about treating `ord` gaps as
#' meaningful without first checking they're not driven by absent data.
#'
#' # Continuous variables: Qst
#' For each variable, partitions the total variance of its (pooled) values
#' across all groups into between-group and within-group components:
#' `Qst = Vb / (Vb + Vw)`, the same decomposition used for genetic Qst,
#' directly analogous to Gst but for a measured quantity rather than
#' discrete states. Ordinal variables are treated this way, using their
#' `ord` rank as the quantity, only when `type_aware = TRUE`.
#'
#' # Missing data
#' D-PLACE's dedicated "no data" sentinel code for each variable (see
#' [get_pairwise_cult_distance()]'s documentation) is excluded before any
#' calculation, exactly as in [get_cult_distance()]. A society with no
#' recorded (non-sentinel) state for a variable simply doesn't contribute to
#' that variable's calculation; `n_societies` in `by_variable` reports how
#' many did.
#'
#' # Overall summary
#' Because Gst and Qst are different statistics on different scales, they
#' are never blended into a single number. Instead `overall` gives one
#' combined value per method actually used, via the standard multi-locus
#' combining method (sum of between-group components over sum of total
#' components across variables, not an average of per-variable ratios,
#' which would let a variable backed by little data distort the result as
#' much as one backed by a lot): `"Gst"` combines every categorical/
#' ordinal-as-categorical variable; `"Qst"` combines every continuous/
#' ordinal-as-quantitative variable, after first rescaling each variable by
#' its own full-dataset range (see [get_pairwise_cult_distance()]'s
#' `type_aware` documentation) so that variables measured on different
#' scales don't dominate the sum just from their raw variance being
#' numerically larger -- this rescaling doesn't change any individual
#' variable's own Qst, only its weight in this combined figure.
#'
#' # A note on interpretation
#' Cultural Fst/Qst values are not directly comparable to genetic Fst
#' values -- published applications of Fst-style statistics to cultural
#' trait data (e.g. Bell, Richerson & McElreath, 2009, PNAS) have found
#' cultural differentiation running roughly an order of magnitude higher
#' than typical genetic Fst between the same groups. Also bear in mind that
#' societies within a group are rarely independent observations -- shared
#' cultural ancestry or geographic diffusion can inflate apparent
#' between-group structure (the same "Galton's Problem" concern that
#' applies throughout cross-cultural research); grouping by [dp_lang_family_list()]
#' family, or checking results against it, is one way to see how much of a
#' result might reflect shared descent rather than independent divergence.
#'
#' @param soc_id Character vector of D-PLACE society IDs spanning at least
#'   two groups (see [dp_societies()]). Also accepts a data frame/tibble
#'   with a `soc_id` column, from which the column is used automatically.
#'   Unknown IDs are dropped with a warning.
#' @param group Assigns each society in `soc_id` to a group -- see Details.
#' @param var_id,category,type,search Optional variable-selection criteria:
#'   `var_id` names variable ID(s) explicitly (also accepting a data
#'   frame/tibble with a `var_id` column), while `category`, `type`,
#'   and `search` select a subset by searching -- all four are passed
#'   straight to [dp_variables()] and combined with AND, like there
#'   (including [contains()] support for `category`). At least one must be
#'   supplied. `var_id` values not found (or not matched by the other
#'   criteria) are dropped with a warning.
#' @param type_aware Logical; if `TRUE`, ordinal variables are scored by Qst
#'   (using `ord` as a quantity) instead of Gst. Default `FALSE` -- see
#'   Details. Does not affect categorical or continuous variables.
#'
#' @return A list with two tibbles:
#' \describe{
#'   \item{`by_variable`}{One row per variable: `var_id`, `type`, `method`
#'     (`"Gst"` or `"Qst"`), `n_groups` and `n_societies` actually used, and
#'     `value`. `value` is `NA` (with a warning) if fewer than two groups
#'     had a recorded value for that variable, or if no diversity/variance
#'     remains among the group(s) that did (e.g. every remaining society
#'     shares the same state).}
#'   \item{`overall`}{One row per method actually used across the requested
#'     variables: `method`, `n_variables` it combines, and `value` -- see
#'     Details.}
#' }
#'
#' @examples
#' \dontrun{
#' get_cultural_FST(
#'   dp_societies(lang_family = c("Indo-European", "Afro-Asiatic"))$soc_id,
#'   group = "lang_family", category = contains("Subsistence")
#' )
#' }
#'
#' @export
get_cultural_FST <- function(soc_id, group, var_id = NULL, category = NULL,
                              type = NULL, search = NULL, type_aware = FALSE) {
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")

  if (length(soc_id) < 2) {
    stop("`soc_id` must contain at least two society IDs.", call. = FALSE)
  }
  if (anyDuplicated(soc_id)) {
    stop("`soc_id` contains duplicate values.", call. = FALSE)
  }
  if (!is.null(var_id) && length(var_id) < 1) {
    stop(
      "`var_id` must contain at least one variable ID (or be omitted to ",
      "select via `category`/`type`/`search` instead).", call. = FALSE
    )
  }
  if (is.null(var_id) && is.null(category) && is.null(type) && is.null(search)) {
    stop(
      "Supply at least one of `var_id`, `category`, `type`, or `search` to ",
      "select which variables to include -- see dp_variables() or ",
      "dp_search_variables() to browse what's available first.", call. = FALSE
    )
  }
  if (!is.null(var_id) && anyDuplicated(var_id)) {
    stop("`var_id` contains duplicate values.", call. = FALSE)
  }

  group_of <- .fst_resolve_group(group, soc_id)

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_soc <- setdiff(soc_id, soc$soc_id)
  if (length(missing_soc) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_soc, collapse = ", "),
      call. = FALSE
    )
  }
  soc_id <- soc$soc_id
  group_of <- unname(group_of[soc_id])

  no_group <- is.na(group_of)
  if (any(no_group)) {
    warning(
      "Dropping society(ies) with no group assigned: ",
      paste(soc_id[no_group], collapse = ", "), call. = FALSE
    )
    soc_id <- soc_id[!no_group]
    group_of <- group_of[!no_group]
  }
  if (length(soc_id) < 2 || length(unique(group_of)) < 2) {
    stop(
      "At least two groups, each with at least one society, are required ",
      "after dropping unknown/ungrouped societies (found ",
      length(unique(group_of)), " group(s)).", call. = FALSE
    )
  }

  vars <- dp_variables(var_id = var_id, category = category, type = type, search = search)
  if (!is.null(var_id)) {
    missing_var <- setdiff(var_id, vars$var_id)
    if (length(missing_var) > 0) {
      warning(
        "Variable ID(s) not found, dropped: ", paste(missing_var, collapse = ", "),
        call. = FALSE
      )
    }
  }
  var_id <- vars$var_id
  if (length(var_id) < 1) {
    stop("No variables matched the given criteria.", call. = FALSE)
  }
  var_type <- stats::setNames(vars$type, vars$var_id)

  vals <- dp_values(var_id = var_id, soc_id = soc_id)
  vals <- .cult_dist_drop_missing_sentinel(vals)
  vals <- .cult_dist_collapse_duplicates(vals)

  state_chr <- matrix(
    NA_character_, nrow = length(soc_id), ncol = length(var_id),
    dimnames = list(soc_id, var_id)
  )
  if (nrow(vals) > 0) {
    idx <- cbind(match(vals$soc_id, soc_id), match(vals$var_id, var_id))
    state_chr[idx] <- ifelse(!is.na(vals$code_id), vals$code_id, vals$value)
  }

  precomputed <- .fst_precompute_all_summaries(state_chr, group_of, var_id, var_type, type_aware)
  raw <- .fst_assemble_raw(precomputed, var_id, group_names = NULL)

  by_variable <- tibble::tibble(
    var_id = var_id, type = raw$type, method = raw$method,
    n_groups = raw$n_groups, n_societies = raw$n_societies, value = raw$value
  )
  overall <- tibble::tibble(
    method = raw$overall_method, n_variables = raw$overall_n_variables, value = raw$overall_value
  )

  na_vars <- by_variable$var_id[is.na(by_variable$value)]
  if (length(na_vars) > 0) {
    warning(
      "Fewer than two groups had a recorded value, or no diversity/variance ",
      "remains among the group(s) that did, for variable(s), value is NA: ",
      paste(na_vars, collapse = ", "), call. = FALSE
    )
  }

  list(by_variable = by_variable, overall = overall)
}
