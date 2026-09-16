#' Pairwise cultural differentiation (Fst-style) between groups of societies
#'
#' Computes the same Gst/Qst-style cultural differentiation as
#' [get_cultural_FST()], but separately for every pair of groups among three
#' or more, rather than one combined calculation across all of them at once
#' -- directly analogous to how [get_pairwise_cult_distance()] relates to
#' [get_cult_distance()], but with groups of societies as the unit of
#' comparison instead of individual societies. See [get_cultural_FST()] for
#' the full explanation of `group`, the Gst/Qst calculations, missing-data
#' handling, and the `overall` summary -- all identical here, just computed
#' once per pair of groups instead of once across all groups together.
#'
#' @inheritParams get_cultural_FST
#'
#' @return A list with two tibbles, each with one row per group pair (in
#'   addition to what [get_cultural_FST()] returns per row):
#' \describe{
#'   \item{`by_variable`}{`group_1`, `group_2`, `var_id`, `type`, `method`,
#'     `n_groups` (always `2`), `n_societies`, `value`.}
#'   \item{`overall`}{`group_1`, `group_2`, `method`, `n_variables`,
#'     `value`.}
#' }
#'
#' @examples
#' \dontrun{
#' get_pairwise_cultural_FST(
#'   dp_societies(lang_family = c("Indo-European", "Afro-Asiatic", "Austronesian"))$soc_id,
#'   group = "lang_family", category = contains("Subsistence")
#' )
#' }
#'
#' @export
get_pairwise_cultural_FST <- function(soc_id, group, var_id = NULL, category = NULL,
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

  # Precomputed ONCE across all groups (not per pair) -- see the performance
  # note in utils-cultural-fst.R. Without this, the number of pairs growing
  # quadratically with the number of groups (e.g. ~200 lang_family groups ->
  # ~20,000 pairs) makes rescanning raw data per pair impractically slow.
  precomputed <- .fst_precompute_all_summaries(state_chr, group_of, var_id, var_type, type_aware)

  groups <- sort(unique(group_of))
  pair_idx <- utils::combn(length(groups), 2)
  n_pairs <- ncol(pair_idx)
  n_var <- length(var_id)

  # Collected as plain vectors across ALL pairs and wrapped in tibble() only
  # once at the end (see the performance note in utils-cultural-fst.R) --
  # tibble()'s per-call overhead, negligible once, dominates runtime if paid
  # per pair for a many-group `group` like lang_family (tens of thousands
  # of pairs).
  bv_group_1 <- character(n_pairs * n_var)
  bv_group_2 <- character(n_pairs * n_var)
  bv_var_id <- rep(var_id, times = n_pairs)
  bv_type <- character(n_pairs * n_var)
  bv_method <- character(n_pairs * n_var)
  bv_n_groups <- integer(n_pairs * n_var)
  bv_n_societies <- integer(n_pairs * n_var)
  bv_value <- numeric(n_pairs * n_var)

  max_overall <- n_pairs * 2 # at most one Gst row and one Qst row per pair
  ov_group_1 <- character(max_overall)
  ov_group_2 <- character(max_overall)
  ov_method <- character(max_overall)
  ov_n_variables <- integer(max_overall)
  ov_value <- numeric(max_overall)
  ov_count <- 0L

  for (p in seq_len(n_pairs)) {
    g1 <- groups[pair_idx[1, p]]
    g2 <- groups[pair_idx[2, p]]
    raw <- .fst_assemble_raw(precomputed, var_id, group_names = c(g1, g2))

    rows <- ((p - 1) * n_var + 1):(p * n_var)
    bv_group_1[rows] <- g1
    bv_group_2[rows] <- g2
    bv_type[rows] <- raw$type
    bv_method[rows] <- raw$method
    bv_n_groups[rows] <- raw$n_groups
    bv_n_societies[rows] <- raw$n_societies
    bv_value[rows] <- raw$value

    k <- length(raw$overall_method)
    if (k > 0) {
      orows <- (ov_count + 1):(ov_count + k)
      ov_group_1[orows] <- g1
      ov_group_2[orows] <- g2
      ov_method[orows] <- raw$overall_method
      ov_n_variables[orows] <- raw$overall_n_variables
      ov_value[orows] <- raw$overall_value
      ov_count <- ov_count + k
    }
  }

  by_variable <- tibble::tibble(
    group_1 = bv_group_1, group_2 = bv_group_2, var_id = bv_var_id, type = bv_type,
    method = bv_method, n_groups = bv_n_groups, n_societies = bv_n_societies, value = bv_value
  )
  overall <- tibble::tibble(
    group_1 = ov_group_1[seq_len(ov_count)], group_2 = ov_group_2[seq_len(ov_count)],
    method = ov_method[seq_len(ov_count)], n_variables = ov_n_variables[seq_len(ov_count)],
    value = ov_value[seq_len(ov_count)]
  )

  na_rows <- sum(is.na(by_variable$value))
  if (na_rows > 0) {
    warning(
      na_rows, " variable/group-pair combination(s) have insufficient data ",
      "(one side of the pair had no recorded value); their `value` is NA.",
      call. = FALSE
    )
  }

  list(by_variable = by_variable, overall = overall)
}
