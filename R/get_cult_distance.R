#' Cultural distance from a specified culture to a list of societies
#'
#' Computes the cultural (dis)similarity, using the same variable-matching
#' approach as [get_pairwise_cult_distance()], between one reference
#' "culture" and each society in a list. The reference culture can be an
#' existing D-PLACE society, a computed modal (most common) profile across a
#' group of societies, or a custom profile you specify directly. For
#' distances between all pairs within a set of societies, use
#' [get_pairwise_cult_distance()] instead.
#'
#' @details
#' # The reference culture (`culture`, `modal`, `mode_ref_soc_id`)
#' `culture` specifies the reference culture, and is one of:
#' \describe{
#'   \item{A single D-PLACE society ID (character)}{Uses that society's own
#'     recorded states.}
#'   \item{A named vector}{A custom profile: names are variable IDs (a
#'     subset of `var_id`), values are the state for each -- either a
#'     code_id (for categorical/ordinal variables, see [dp_codes()]) or a
#'     numeric value (for continuous variables).}
#'   \item{`NULL`}{Required when `modal = TRUE` (see below); an error
#'     otherwise.}
#' }
#'
#' If `modal = TRUE`, `culture` is ignored (with a warning if supplied) and
#' the reference culture is instead the modal (most common) state for each
#' variable across a reference group of societies -- `soc_id` itself by
#' default, or `mode_ref_soc_id` if given, e.g. to compute the mode from a
#' different/larger group than the one you're comparing distances for.
#' Societies missing a variable don't count toward that variable's vote; if
#' two or more states are tied for most common, the first (alphabetically)
#' is used and a warning lists which variable(s) were affected; if none of
#' the reference group has a recorded state for a variable, it's `NA` for
#' the modal profile (and so behaves as a missing value for it, per
#' `missing`, below).
#'
#' # Missing data (`missing`)
#' Adapted from [get_pairwise_cult_distance()] for a one-vs-many comparison:
#' \describe{
#'   \item{`"pairwise"` (default)}{For each society, only variables where
#'     BOTH `culture` and that society have a recorded state are compared;
#'     `n_compared` can differ from society to society.}
#'   \item{`"complete"`}{Variables `culture` itself has no state for are
#'     dropped entirely (there's nothing to compare against for anyone);
#'     societies missing any of the remaining variables are then dropped
#'     too (with a warning), so every remaining society is compared on the
#'     same full variable set.}
#'   \item{`"match"`}{Missingness is treated as its own state: `culture`
#'     and a society both missing a variable count as matching on it, and
#'     one missing it while the other doesn't counts as differing. Every
#'     variable therefore contributes to every society's comparison.}
#' }
#'
#' `metric` and `type_aware` behave exactly as in
#' [get_pairwise_cult_distance()] (see its documentation for details and
#' the same duplicate-observation handling).
#'
#' @param culture The reference culture -- see Details. Ignored if
#'   `modal = TRUE`.
#' @param soc_id Character vector of one or more D-PLACE society IDs to
#'   compare `culture` against (see [dp_societies()]). Also accepts a data
#'   frame/tibble with a `soc_id` column, from which the column is used
#'   automatically.
#' @param var_id,category,type,search Optional variable-selection criteria:
#'   `var_id` names variable ID(s) explicitly (also accepting a data
#'   frame/tibble with a `var_id` column), while `category`, `type`,
#'   and `search` select a subset by searching -- all four are passed
#'   straight to [dp_variables()] and combined with AND, like there
#'   (including [contains()] support for `category`). At least one must be
#'   supplied. `var_id` values not found (or not matched by the other
#'   criteria) are dropped with a warning.
#' @param modal Logical; if `TRUE`, compute the reference culture as a
#'   modal profile instead of using `culture` -- see Details. Default
#'   `FALSE`.
#' @param mode_ref_soc_id Optional character vector of society IDs to
#'   compute the modal profile from, when `modal = TRUE`, instead of using
#'   `soc_id` (also accepts a data frame/tibble with a `soc_id` column).
#'   Ignored unless `modal = TRUE`.
#' @param missing One of `"pairwise"` (default), `"complete"`, or `"match"`
#'   -- see Details.
#' @param metric One of `"proportion"` (default), `"both"`, or `"sum"` --
#'   see [get_pairwise_cult_distance()].
#' @param type_aware Logical; score ordinal/continuous variables by scaled
#'   difference rather than simple match/mismatch. Default `FALSE`. See
#'   [get_pairwise_cult_distance()].
#'
#' @return A tibble with one row per society in `soc_id` (after dropping any
#'   as described above): `soc_id`, and columns determined by `metric` (see
#'   [get_pairwise_cult_distance()]).
#'
#' @examples
#' \dontrun{
#' get_cult_distance("B72", c("B73", "B79"), var_id = c("B004", "B005"))
#' get_cult_distance(NULL, c("B72", "B73", "B79"), var_id = c("B004", "B005"),
#'                    modal = TRUE)
#' get_cult_distance("B72", c("B73", "B79"), category = contains("Subsistence"))
#' }
#'
#' @export
get_cult_distance <- function(culture = NULL, soc_id, var_id = NULL, category = NULL,
                               type = NULL, search = NULL, modal = FALSE,
                               mode_ref_soc_id = NULL,
                               missing = c("pairwise", "complete", "match"),
                               metric = c("proportion", "both", "sum"),
                               type_aware = FALSE) {
  missing <- match.arg(missing)
  metric <- match.arg(metric)
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")
  mode_ref_soc_id <- .gs_coerce_ids(mode_ref_soc_id, "soc_id", "mode_ref_soc_id")

  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
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

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_soc <- setdiff(soc_id, soc$soc_id)
  if (length(missing_soc) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_soc, collapse = ", "),
      call. = FALSE
    )
  }
  soc_id <- soc$soc_id
  if (length(soc_id) < 1) {
    stop("None of the requested society IDs were found.", call. = FALSE)
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

  profile <- .cult_dist_resolve_culture(
    culture, soc_id, var_id, modal, mode_ref_soc_id
  )

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

  if (missing == "complete") {
    profile_missing_vars <- var_id[is.na(profile)]
    if (length(profile_missing_vars) > 0) {
      warning(
        "Dropping variable(s) the reference culture has no state for ",
        "(missing = \"complete\"): ", paste(profile_missing_vars, collapse = ", "),
        call. = FALSE
      )
      var_id <- setdiff(var_id, profile_missing_vars)
      profile <- profile[var_id]
      state_chr <- state_chr[, var_id, drop = FALSE]
      var_type <- var_type[var_id]
      if (length(var_id) < 1) {
        stop("The reference culture has no state for any requested variable.",
             call. = FALSE)
      }
    }

    complete_rows <- rowSums(is.na(state_chr)) == 0
    dropped <- soc_id[!complete_rows]
    if (length(dropped) > 0) {
      warning(
        "Dropping societies missing data for one or more comparable variables ",
        "(missing = \"complete\"): ", paste(dropped, collapse = ", "),
        call. = FALSE
      )
    }
    soc_id <- soc_id[complete_rows]
    state_chr <- state_chr[complete_rows, , drop = FALSE]
    if (length(soc_id) < 1) {
      stop("No societies with complete data for all comparable variables remain.",
           call. = FALSE)
    }
  }

  n_soc <- length(soc_id)
  n_match <- numeric(n_soc)
  n_compared <- numeric(n_soc)

  for (v in var_id) {
    vtype <- var_type[[v]]
    use_scaled <- isTRUE(type_aware) && !is.na(vtype) && vtype %in% c("Ordinal", "Continuous")

    numeric_col <- NULL
    prof_numeric <- NA_real_
    rng <- NA_real_
    if (use_scaled) {
      rng <- .cult_dist_var_range(v, vtype)
      if (is.na(rng) || rng == 0) {
        use_scaled <- FALSE
      } else {
        numeric_col <- .cult_dist_numeric_col(state_chr[, v], v, vtype)
        prof_numeric <- .cult_dist_numeric_col(profile[[v]], v, vtype)
      }
    }

    if (use_scaled) {
      present <- unname(!is.na(numeric_col))
      prof_present <- !is.na(prof_numeric)
      xi <- unname(numeric_col)
    } else {
      present <- unname(!is.na(state_chr[, v]))
      prof_present <- !is.na(profile[[v]])
      xi <- unname(state_chr[, v])
    }

    both_present <- present & prof_present

    sim <- rep(NA_real_, n_soc)
    if (use_scaled) {
      sim[both_present] <- pmax(0, 1 - abs(xi[both_present] - prof_numeric) / rng)
    } else {
      sim[both_present] <- as.numeric(xi[both_present] == profile[[v]])
    }

    if (missing == "match") {
      both_missing <- !present & !prof_present
      one_missing <- xor(present, prof_present)
      sim[both_missing] <- 1
      sim[one_missing] <- 0
      valid <- rep(TRUE, n_soc)
    } else {
      valid <- both_present
    }

    n_match <- n_match + ifelse(valid & !is.na(sim), sim, 0)
    n_compared <- n_compared + as.numeric(valid)
  }

  no_overlap <- n_compared == 0
  if (any(no_overlap)) {
    warning(
      "The reference culture and ", sum(no_overlap), " society(ies) had no ",
      "variable in common; their `cult_distance` is NA. Society(ies): ",
      paste(soc_id[no_overlap], collapse = ", "), call. = FALSE
    )
  }

  cult_distance <- ifelse(n_compared > 0, 1 - n_match / n_compared, NA_real_)

  out <- tibble::tibble(soc_id = soc_id)
  out <- switch(
    metric,
    proportion = { out$cult_distance <- cult_distance; out },
    both = { out$n_match <- n_match; out$n_compared <- n_compared; out$cult_distance <- cult_distance; out },
    sum = { out$n_match <- n_match; out }
  )

  out
}

# --- internal helpers (not exported) ----------------------------------------

# Resolve `culture`/`modal`/`mode_ref_soc_id` into a single named character
# vector (one state per var_id, NA where unknown).
.cult_dist_resolve_culture <- function(culture, soc_id, var_id, modal, mode_ref_soc_id) {
  if (isTRUE(modal)) {
    if (!is.null(culture)) {
      warning("`culture` is ignored when modal = TRUE.", call. = FALSE)
    }
    if (is.null(mode_ref_soc_id)) {
      ref_soc_id <- soc_id
    } else {
      ref <- dp_societies(soc_id = mode_ref_soc_id, type = NULL)
      missing_ref <- setdiff(mode_ref_soc_id, ref$soc_id)
      if (length(missing_ref) > 0) {
        warning(
          "mode_ref_soc_id: society ID(s) not found, dropped: ",
          paste(missing_ref, collapse = ", "), call. = FALSE
        )
      }
      if (nrow(ref) < 1) {
        stop("None of the `mode_ref_soc_id` society IDs were found.", call. = FALSE)
      }
      ref_soc_id <- ref$soc_id
    }
    return(.cult_dist_modal_profile(ref_soc_id, var_id))
  }

  if (is.null(culture)) {
    stop(
      "`culture` must be supplied (a society ID or a named state vector), ",
      "or set modal = TRUE.", call. = FALSE
    )
  }

  if (is.numeric(culture) && !is.null(names(culture))) {
    culture <- stats::setNames(as.character(culture), names(culture))
  }

  if (is.character(culture) && length(culture) == 1 && is.null(names(culture))) {
    cs <- dp_societies(soc_id = culture, type = NULL)
    if (nrow(cs) == 0) {
      stop("`culture` society ID not found: ", culture, call. = FALSE)
    }
    cv <- dp_values(var_id = var_id, soc_id = culture)
    cv <- .cult_dist_drop_missing_sentinel(cv)
    cv <- .cult_dist_collapse_duplicates(cv)
    profile <- stats::setNames(rep(NA_character_, length(var_id)), var_id)
    if (nrow(cv) > 0) {
      profile[cv$var_id] <- ifelse(!is.na(cv$code_id), cv$code_id, cv$value)
    }
    return(profile)
  }

  if (is.character(culture) && !is.null(names(culture))) {
    unknown <- setdiff(names(culture), var_id)
    if (length(unknown) > 0) {
      warning(
        "`culture` has state(s) for variable(s) not in `var_id`, ignored: ",
        paste(unknown, collapse = ", "), call. = FALSE
      )
    }
    profile <- stats::setNames(rep(NA_character_, length(var_id)), var_id)
    keep <- intersect(names(culture), var_id)
    profile[keep] <- culture[keep]
    return(profile)
  }

  stop(
    "`culture` must be a single D-PLACE society ID, a named vector of ",
    "variable states, or NULL with modal = TRUE.", call. = FALSE
  )
}

# Modal (most common) state per var_id across ref_soc_id, excluding
# societies missing that variable from the vote. Ties broken alphabetically
# with a warning; a variable with no data in ref_soc_id is NA.
.cult_dist_modal_profile <- function(ref_soc_id, var_id) {
  vals <- dp_values(var_id = var_id, soc_id = ref_soc_id)
  vals <- .cult_dist_drop_missing_sentinel(vals)
  vals <- .cult_dist_collapse_duplicates(vals)

  profile <- stats::setNames(rep(NA_character_, length(var_id)), var_id)
  if (nrow(vals) == 0) {
    return(profile)
  }
  vals$state <- ifelse(!is.na(vals$code_id), vals$code_id, vals$value)
  # Split once up front rather than re-scanning `vals` per variable -- matters
  # when var_id/ref_soc_id cover the whole bundled dataset (thousands of
  # variables x thousands of societies).
  states_by_var <- split(vals$state, vals$var_id)

  tied_vars <- character(0)
  for (v in var_id) {
    states <- states_by_var[[v]]
    if (is.null(states)) {
      next
    }
    states <- states[!is.na(states)]
    if (length(states) == 0) {
      next
    }
    tab <- table(states)
    top <- sort(names(tab)[tab == max(tab)])
    if (length(top) > 1) {
      tied_vars <- c(tied_vars, v)
    }
    profile[[v]] <- top[1]
  }

  if (length(tied_vars) > 0) {
    warning(
      "Variable(s) with a tied modal state in the reference group (first ",
      "alphabetically used): ", paste(tied_vars, collapse = ", "), call. = FALSE
    )
  }

  profile
}
