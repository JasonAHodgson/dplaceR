#' Pairwise cultural distance between societies
#'
#' Computes a pairwise cultural (dis)similarity between D-PLACE societies
#' from the coded states of one or more cultural variables: for each pair of
#' societies, and for each requested variable, the two societies either
#' match (the same coded state) or don't, and the per-variable results are
#' combined across variables into a single measure per pair.
#'
#' @details
#' # Missing data (`missing`)
#' A society may lack a recorded value for one of the requested variables.
#' `missing` controls how that's handled:
#' \describe{
#'   \item{`"pairwise"` (default)}{For each pair, only variables where BOTH
#'     societies have a recorded state are compared; the number of variables
#'     compared (`n_compared`) can differ from pair to pair.}
#'   \item{`"complete"`}{Societies missing a value for ANY requested
#'     variable are dropped from the calculation entirely (with a warning),
#'     so every remaining pair is compared on the full set of `var_id`
#'     (`n_compared` is always `length(var_id)`).}
#'   \item{`"match"`}{Missingness is treated as its own state: two societies
#'     both missing a variable count as matching on it, and a society
#'     missing a variable that another has counts as differing on it. Every
#'     variable therefore contributes to every pair (`n_compared` is always
#'     `length(var_id)`).}
#' }
#'
#' # Combining variables (`metric`)
#' \describe{
#'   \item{`"proportion"` (default)}{Returns a single `cult_distance` column:
#'     the proportion of compared variables the two societies differ on (`0` =
#'     identical on everything compared, `1` = differ on everything
#'     compared).}
#'   \item{`"both"`}{Also returns the underlying `n_match` (sum of
#'     per-variable similarity) and `n_compared` counts alongside
#'     `cult_distance`.}
#'   \item{`"sum"`}{Returns only `n_match`: the raw, unnormalized sum of
#'     per-variable similarity across the compared variables -- how many
#'     (or, with `type_aware = TRUE`, how much) of the compared variables the
#'     two societies share. Not comparable between pairs with different
#'     `n_compared` (see `"both"` or `"proportion"` for that).}
#' }
#'
#' # Variable type (`type_aware`)
#' By default (`type_aware = FALSE`) every variable is scored the same way:
#' identical coded state = similarity `1`, anything else = `0`, regardless of
#' whether D-PLACE calls the variable categorical, ordinal, or continuous.
#' With `type_aware = TRUE`, categorical variables are still scored this way,
#' but ordinal and continuous variables instead score *partial* similarity
#' based on how far apart the two states are: for ordinal variables, using
#' the code's rank ([dp_codes()]'s `ord` column); for continuous variables,
#' using the numeric value. In both cases the absolute difference is
#' rescaled by the variable's range across *all* societies that have a
#' recorded value for it (in the full bundled dataset, not just `soc_id`),
#' so a small difference on a wide-ranging variable counts for less than the
#' same difference on a narrow one. A variable with zero range (a single
#' observed state/value across the whole dataset) falls back to simple
#' match/mismatch for that variable.
#'
#' Societies with multiple recorded observations for the same variable (a
#' small number of variables in D-PLACE have more than one, from different
#' sources/years) are collapsed to a single value per society/variable
#' before comparison: the most recent by `year` where known, otherwise the
#' first recorded. A warning reports how many society/variable combinations
#' were collapsed this way; use [dp_values()] yourself first if you want
#' different control over this.
#'
#' @param soc_id Character vector of two or more D-PLACE society IDs (see
#'   [dp_societies()]). Unknown IDs are dropped with a warning.
#' @param var_id,category,type,search Optional variable-selection criteria:
#'   `var_id` names variable ID(s) explicitly, while `category`, `type`,
#'   and `search` select a subset by searching -- all four are passed
#'   straight to [dp_variables()] and combined with AND, like there
#'   (including [contains()] support for `category`). At least one must be
#'   supplied. `var_id` values not found (or not matched by the other
#'   criteria) are dropped with a warning.
#' @param missing One of `"pairwise"` (default), `"complete"`, or `"match"`
#'   -- see Details.
#' @param metric One of `"proportion"` (default), `"both"`, or `"sum"` --
#'   see Details.
#' @param type_aware Logical; if `TRUE`, score ordinal/continuous variables
#'   by scaled difference rather than simple match/mismatch. Default
#'   `FALSE`. See Details.
#'
#' @return A tibble with one row per unique pair of the input societies:
#'   `soc_id_1`, `soc_id_2`, and columns determined by `metric` (see
#'   Details). Under `missing = "pairwise"`, a pair with no variable in
#'   common (`n_compared == 0`) gets `cult_distance` `NA` (or, under
#'   `metric = "sum"`, `n_match` `0`), with a warning.
#'
#' @examples
#' \dontrun{
#' get_pairwise_cult_distance(c("B72", "B73", "B79"), var_id = c("B004", "B005"))
#' get_pairwise_cult_distance(c("B72", "B73", "B79"), category = contains("Subsistence"))
#' }
#'
#' @export
get_pairwise_cult_distance <- function(soc_id, var_id = NULL, category = NULL,
                                        type = NULL, search = NULL,
                                        missing = c("pairwise", "complete", "match"),
                                        metric = c("proportion", "both", "sum"),
                                        type_aware = FALSE) {
  missing <- match.arg(missing)
  metric <- match.arg(metric)

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

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_soc <- setdiff(soc_id, soc$soc_id)
  if (length(missing_soc) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_soc, collapse = ", "),
      call. = FALSE
    )
  }
  soc_id <- soc$soc_id
  if (length(soc_id) < 2) {
    stop("Fewer than two valid society IDs were found.", call. = FALSE)
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
  if (length(var_id) == 1) {
    warning(
      "Only one variable requested; `cult_distance` will only take the values 0 and 1.",
      call. = FALSE
    )
  }
  var_type <- stats::setNames(vars$type, vars$var_id)

  vals <- dp_values(var_id = var_id, soc_id = soc_id)
  vals <- .cult_dist_collapse_duplicates(vals)

  # soc x var matrix of raw states (code_id for categorical/ordinal, raw
  # character value for continuous; NA where no observation).
  state_chr <- matrix(
    NA_character_, nrow = length(soc_id), ncol = length(var_id),
    dimnames = list(soc_id, var_id)
  )
  if (nrow(vals) > 0) {
    idx <- cbind(match(vals$soc_id, soc_id), match(vals$var_id, var_id))
    state_chr[idx] <- ifelse(!is.na(vals$code_id), vals$code_id, vals$value)
  }

  if (missing == "complete") {
    complete_rows <- rowSums(is.na(state_chr)) == 0
    dropped <- soc_id[!complete_rows]
    if (length(dropped) > 0) {
      warning(
        "Dropping societies missing data for one or more requested variables ",
        "(missing = \"complete\"): ", paste(dropped, collapse = ", "),
        call. = FALSE
      )
    }
    soc_id <- soc_id[complete_rows]
    state_chr <- state_chr[complete_rows, , drop = FALSE]
    if (length(soc_id) < 2) {
      stop("Fewer than two societies with complete data for all requested variables remain.",
           call. = FALSE)
    }
  }

  n_soc <- length(soc_id)
  pairs_idx <- utils::combn(n_soc, 2)
  n_pairs <- ncol(pairs_idx)
  i <- pairs_idx[1, ]
  j <- pairs_idx[2, ]

  n_match <- numeric(n_pairs)
  n_compared <- numeric(n_pairs)

  for (v in var_id) {
    vtype <- var_type[[v]]
    use_scaled <- isTRUE(type_aware) && !is.na(vtype) && vtype %in% c("Ordinal", "Continuous")

    numeric_col <- NULL
    rng <- NA_real_
    if (use_scaled) {
      rng <- .cult_dist_var_range(v, vtype)
      if (is.na(rng) || rng == 0) {
        use_scaled <- FALSE
      } else {
        numeric_col <- .cult_dist_numeric_col(state_chr[, v], v, vtype)
      }
    }

    if (use_scaled) {
      present <- unname(!is.na(numeric_col))
      xi <- unname(numeric_col[i])
      xj <- unname(numeric_col[j])
    } else {
      present <- unname(!is.na(state_chr[, v]))
      xi <- unname(state_chr[i, v])
      xj <- unname(state_chr[j, v])
    }
    pres_i <- present[i]
    pres_j <- present[j]
    both_present <- pres_i & pres_j

    sim <- rep(NA_real_, n_pairs)
    if (use_scaled) {
      sim[both_present] <- pmax(
        0, 1 - abs(as.numeric(xi[both_present]) - as.numeric(xj[both_present])) / rng
      )
    } else {
      sim[both_present] <- as.numeric(xi[both_present] == xj[both_present])
    }

    if (missing == "match") {
      both_missing <- !pres_i & !pres_j
      one_missing <- xor(pres_i, pres_j)
      sim[both_missing] <- 1
      sim[one_missing] <- 0
      valid <- rep(TRUE, n_pairs)
    } else {
      valid <- both_present
    }

    n_match <- n_match + ifelse(valid & !is.na(sim), sim, 0)
    n_compared <- n_compared + as.numeric(valid)
  }

  no_overlap <- n_compared == 0
  if (any(no_overlap)) {
    warning(
      "No requested variable had data for both societies in ",
      sum(no_overlap), " pair(s); their `cult_distance` is NA. Pair(s): ",
      paste(soc_id[i[no_overlap]], soc_id[j[no_overlap]], sep = "-", collapse = ", "),
      call. = FALSE
    )
  }

  cult_distance <- ifelse(n_compared > 0, 1 - n_match / n_compared, NA_real_)

  out <- tibble::tibble(
    soc_id_1 = soc_id[i],
    soc_id_2 = soc_id[j]
  )

  out <- switch(
    metric,
    proportion = { out$cult_distance <- cult_distance; out },
    both = { out$n_match <- n_match; out$n_compared <- n_compared; out$cult_distance <- cult_distance; out },
    sum = { out$n_match <- n_match; out }
  )

  out
}

# --- internal helpers (not exported) ---------------------------------------

# Collapse multiple observations of the same soc_id/var_id combination
# (a small number of D-PLACE variables have more than one, from different
# sources/years) to a single row: most recent `year`, or the first recorded
# where `year` is unknown/tied.
.cult_dist_collapse_duplicates <- function(vals) {
  if (nrow(vals) == 0) {
    return(vals)
  }
  key <- paste(vals$soc_id, vals$var_id)
  year_effective <- ifelse(is.na(vals$year), -Inf, vals$year)
  ord <- order(key, -year_effective)
  vals <- vals[ord, , drop = FALSE]
  keep <- !duplicated(paste(vals$soc_id, vals$var_id))
  n_dropped <- sum(!keep)
  if (n_dropped > 0) {
    warning(
      n_dropped, " duplicate society/variable observation(s) collapsed to a single ",
      "value each (kept the most recent by year, or the first recorded where year ",
      "is unknown/tied). Use dp_values() yourself first for different control over this.",
      call. = FALSE
    )
  }
  vals[keep, , drop = FALSE]
}

# Range (max - min) of a variable's values, in the units used for
# type_aware scoring (ordinal rank, or the raw numeric value), across ALL
# societies in the full bundled dataset -- not just the queried soc_id.
.cult_dist_var_range <- function(var, var_type) {
  if (identical(var_type, "Continuous")) {
    x <- suppressWarnings(as.numeric(dplace_values$value[dplace_values$var_id == var]))
  } else if (identical(var_type, "Ordinal")) {
    codes <- dplace_codes[dplace_codes$var_id == var, c("code_id", "ord")]
    v <- dplace_values$code_id[dplace_values$var_id == var]
    x <- codes$ord[match(v, codes$code_id)]
  } else {
    return(NA_real_)
  }
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(NA_real_)
  }
  diff(range(x))
}

# Numeric representation of a variable's states (ordinal rank, or the raw
# numeric value) for one column of `state_chr` (i.e. just the queried
# societies).
.cult_dist_numeric_col <- function(state_col, var, var_type) {
  if (identical(var_type, "Continuous")) {
    suppressWarnings(as.numeric(state_col))
  } else {
    codes <- dplace_codes[dplace_codes$var_id == var, c("code_id", "ord")]
    codes$ord[match(state_col, codes$code_id)]
  }
}
