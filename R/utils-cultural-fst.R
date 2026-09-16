# Shared internals for get_cultural_FST() and get_pairwise_cultural_FST():
# resolving the `group` argument, computing Nei's Gst (categorical, and
# ordinal by default) and a variance-ratio Qst (continuous, and ordinal with
# type_aware = TRUE) for one variable across an arbitrary number of groups,
# and combining per-variable results into the by_variable/overall output
# shared by both functions.
#
# Performance note: get_pairwise_cultural_FST() computes one value per PAIR
# of groups, and the number of pairs grows quadratically with the number of
# groups (e.g. ~200 lang_family groups -> ~20,000 pairs). Recomputing Gst/Qst
# from scratch for each pair by rescanning that pair's raw society-level data
# would cost roughly (number of pairs) x (average group size) per variable --
# for the whole bundled dataset grouped by lang_family, hundreds of millions
# of element scans, in practice too slow. Instead, each group's Gst/Qst
# sufficient statistics (state counts and gene diversity for Gst; mean and
# sum of squared deviations for Qst) are computed ONCE per variable across
# all groups (.fst_group_summaries_gst()/.fst_group_summaries_qst()), and
# combining any subset of groups' summaries into a Gst/Qst value
# (.fst_combine_gst()/.fst_combine_qst()) is then cheap -- no rescanning of
# raw data is needed per pair. This is mathematically identical to computing
# each pair from scratch (these are exact sufficient statistics, not an
# approximation), just far cheaper.

# Resolve `group` into a character vector named by `soc_id` (the *original*,
# pre-filtering society IDs the caller supplied), so it can be safely
# re-subset later once unknown society IDs have been dropped. Accepts:
#  - "region", "lang_family", or "lang_family_id" (a column of
#    dp_societies()) -- looked up per soc_id;
#  - a named vector (names = soc_id) -- robust to soc_id's order;
#  - an unnamed vector the same length as soc_id -- assigned by position.
.fst_resolve_group <- function(group, soc_id) {
  if (is.character(group) && length(group) == 1 && is.null(names(group))) {
    if (!group %in% c("region", "lang_family", "lang_family_id")) {
      stop(
        "`group` as a single string must be one of \"region\", ",
        "\"lang_family\", or \"lang_family_id\" (a column of dp_societies()) ",
        "-- or supply a vector assigning each society to a group directly.",
        call. = FALSE
      )
    }
    soc <- dp_societies(soc_id = soc_id, type = NULL)
    resolved <- stats::setNames(rep(NA_character_, length(soc_id)), soc_id)
    resolved[soc$soc_id] <- soc[[group]]
    return(resolved)
  }

  if (!is.null(names(group))) {
    unknown <- setdiff(soc_id, names(group))
    if (length(unknown) > 0) {
      stop(
        "`group` (a named vector) is missing entries for society ID(s): ",
        paste(unknown, collapse = ", "), call. = FALSE
      )
    }
    return(stats::setNames(as.character(unname(group[soc_id])), soc_id))
  }

  if (length(group) != length(soc_id)) {
    stop(
      "`group` must be \"region\", \"lang_family\", or \"lang_family_id\", a ",
      "named vector (names = soc_id), or an unnamed vector the same length ",
      "as `soc_id`.", call. = FALSE
    )
  }
  stats::setNames(as.character(group), soc_id)
}

# Per-group Gst sufficient statistics for one categorical (or
# ordinal-as-categorical) variable: for every group with at least one
# non-missing observation, its observation count `n`, its state counts
# (a table), and its own within-group gene diversity `Hg` (Nei, 1973).
# `state_col` and `group_vec` are parallel vectors (one element per
# society); NA entries in either (including a society whose only recorded
# value was D-PLACE's missing-data sentinel, already dropped upstream) are
# excluded first.
#
# Stored as flat named vectors/lists (one element per group), not a list of
# per-group lists -- so that .fst_combine_gst() can subset the groups it
# needs with a single vectorized named-index operation instead of looping
# with Filter()/vapply() over small list elements, which profiling showed
# was itself a meaningful cost once summary lookup (rather than raw-data
# rescanning) became the bottleneck.
.fst_group_summaries_gst <- function(state_col, group_vec) {
  keep <- !is.na(state_col) & !is.na(group_vec)
  state_col <- state_col[keep]
  group_vec <- group_vec[keep]
  groups <- unique(group_vec)
  n <- stats::setNames(numeric(length(groups)), groups)
  Hg <- stats::setNames(numeric(length(groups)), groups)
  counts <- vector("list", length(groups))
  names(counts) <- groups
  for (g in groups) {
    x <- state_col[group_vec == g]
    tab <- table(x)
    n[[g]] <- length(x)
    Hg[[g]] <- 1 - sum((tab / length(x))^2)
    counts[[g]] <- tab
  }
  list(n = n, Hg = Hg, counts = counts)
}

# Per-group Qst sufficient statistics for one continuous (or
# ordinal-as-quantitative, with type_aware = TRUE) variable: for every group
# with at least one non-missing value, its count `n`, mean, and sum of
# squared deviations from its own mean (`ss`) -- enough to reconstruct
# within- and between-group variance for any subset of groups without
# revisiting the raw values.
.fst_group_summaries_qst <- function(numeric_col, group_vec) {
  keep <- !is.na(numeric_col) & !is.na(group_vec)
  numeric_col <- numeric_col[keep]
  group_vec <- group_vec[keep]
  groups <- unique(group_vec)
  n <- stats::setNames(numeric(length(groups)), groups)
  mean_ <- stats::setNames(numeric(length(groups)), groups)
  ss <- stats::setNames(numeric(length(groups)), groups)
  for (g in groups) {
    x <- numeric_col[group_vec == g]
    m <- mean(x)
    n[[g]] <- length(x)
    mean_[[g]] <- m
    ss[[g]] <- sum((x - m)^2)
  }
  list(n = n, mean = mean_, ss = ss)
}

# Elementwise-sum two named count tables/vectors, treating a state present
# in only one as 0 in the other.
.fst_add_tables <- function(a, b) {
  states <- union(names(a), names(b))
  result <- stats::setNames(numeric(length(states)), states)
  result[names(a)] <- result[names(a)] + as.numeric(a)
  result[names(b)] <- result[names(b)] + as.numeric(b)
  result
}

# Combine an arbitrary subset of groups' precomputed Gst summaries (see
# .fst_group_summaries_gst()) into Ht/Hs/Gst -- exactly Nei's Gst computed
# from the pooled raw data of just those groups, without revisiting it.
# `group_names` selects which groups to include (NULL for all of them).
.fst_combine_gst <- function(gst_summary, group_names = NULL) {
  n <- gst_summary$n
  Hg <- gst_summary$Hg
  counts <- gst_summary$counts
  if (!is.null(group_names)) {
    idx <- stats::na.omit(match(group_names, names(n)))
    n <- n[idx]
    Hg <- Hg[idx]
    counts <- counts[idx]
  }
  keep <- n > 0
  n <- n[keep]
  n_groups <- length(n)
  n_total <- sum(n)
  if (n_groups < 2 || n_total == 0) {
    return(list(value = NA_real_, n_groups = n_groups, n_societies = n_total,
                Ht = NA_real_, Hs = NA_real_))
  }
  Hg <- Hg[keep]
  counts <- counts[keep]

  Hs <- sum(n * Hg) / n_total

  pooled <- counts[[1]]
  for (i in seq_along(counts)[-1]) {
    pooled <- .fst_add_tables(pooled, counts[[i]])
  }
  p <- as.numeric(pooled) / n_total
  Ht <- 1 - sum(p^2)

  value <- if (Ht > 0) (Ht - Hs) / Ht else NA_real_
  list(value = value, n_groups = n_groups, n_societies = n_total, Ht = Ht, Hs = Hs)
}

# Combine an arbitrary subset of groups' precomputed Qst summaries (see
# .fst_group_summaries_qst()) into Vb/Vw/Qst -- exactly the same
# between-/within-group variance decomposition computed from the pooled raw
# values of just those groups, without revisiting them. `group_names`
# selects which groups to include (NULL for all of them).
.fst_combine_qst <- function(qst_summary, group_names = NULL) {
  n <- qst_summary$n
  mean_ <- qst_summary$mean
  ss <- qst_summary$ss
  if (!is.null(group_names)) {
    idx <- stats::na.omit(match(group_names, names(n)))
    n <- n[idx]
    mean_ <- mean_[idx]
    ss <- ss[idx]
  }
  keep <- n > 0
  n <- n[keep]
  n_groups <- length(n)
  n_total <- sum(n)
  if (n_groups < 2 || n_total == 0) {
    return(list(value = NA_real_, n_groups = n_groups, n_societies = n_total,
                Vb = NA_real_, Vw = NA_real_))
  }
  mean_ <- mean_[keep]
  ss <- ss[keep]

  grand_mean <- sum(n * mean_) / n_total
  Vb <- sum(n * (mean_ - grand_mean)^2) / n_total
  Vw <- sum(ss) / n_total

  value <- if ((Vb + Vw) > 0) Vb / (Vb + Vw) else NA_real_
  list(value = value, n_groups = n_groups, n_societies = n_total, Vb = Vb, Vw = Vw)
}

# Precompute every requested variable's per-group summaries ONCE (see the
# performance note above) -- shared by get_cultural_FST() (which combines
# every group's summary) and get_pairwise_cultural_FST() (which combines
# just two groups' summaries at a time, per pair, from this same
# precomputed set). `state_chr` is the soc x var matrix of raw states/values
# built exactly as in the get_cult_distance() family; `group_vec` is a
# matching group label per row (its full set of societies/groups, not
# restricted to any one pair).
.fst_precompute_all_summaries <- function(state_chr, group_vec, var_id, var_type, type_aware) {
  out <- vector("list", length(var_id))
  names(out) <- var_id
  for (v in var_id) {
    vtype <- var_type[[v]]
    use_qst <- identical(vtype, "Continuous") ||
      (identical(vtype, "Ordinal") && isTRUE(type_aware))
    if (use_qst) {
      numeric_col <- .cult_dist_numeric_col(state_chr[, v], v, vtype)
      summaries <- .fst_group_summaries_qst(numeric_col, group_vec)
      method <- "Qst"
      # Cached here (once per variable) rather than in .fst_assemble_raw()
      # (once per pair): .cult_dist_var_range() rescans the FULL bundled
      # dataset for this variable every call, and profiling showed it
      # dominating get_pairwise_cultural_FST()'s runtime when called once
      # per pair -- tens of thousands of times for a many-group `group`.
      rng <- .cult_dist_var_range(v, vtype)
    } else {
      summaries <- .fst_group_summaries_gst(state_chr[, v], group_vec)
      method <- "Gst"
      rng <- NA_real_
    }
    out[[v]] <- list(type = vtype, method = method, summaries = summaries, rng = rng)
  }
  out
}

# Assemble the by_variable/overall results, as plain vectors (NOT tibbles --
# see the performance note below), for a chosen subset of groups
# (`group_names`, or NULL for all of them) from precomputed summaries (see
# .fst_precompute_all_summaries()) -- the shared engine behind
# get_cultural_FST() (called once, with group_names = NULL) and
# get_pairwise_cultural_FST() (called once per pair, with group_names of
# length 2). "overall" combines Gst results and Qst results separately via
# summed between-group/total components across variables (the standard
# multi-locus combining method, not an average of per-variable ratios).
# Qst components are rescaled by each variable's own full-dataset range
# before being summed into the overall Qst, so variables on different
# natural scales don't dominate the sum just from having numerically larger
# raw variance; this rescaling doesn't affect any variable's own
# (scale-invariant) Qst value. Gst and Qst are never combined with each
# other, since they're different statistics on different scales.
#
# Performance note: this deliberately returns plain vectors rather than a
# tibble. tibble::tibble() has enough fixed per-call overhead (NSE column
# capture, etc. -- confirmed by profiling) that calling it once per pair in
# get_pairwise_cultural_FST() -- tens of thousands of times for a
# many-group `group` like lang_family -- dominated total runtime even after
# the summary-precomputation fix above. Both exported functions build
# exactly one tibble() each from vectors assembled over all pairs at once.
.fst_assemble_raw <- function(precomputed, var_id, group_names = NULL) {
  n_var <- length(var_id)
  out_type <- character(n_var)
  out_method <- character(n_var)
  out_n_groups <- integer(n_var)
  out_n_societies <- integer(n_var)
  out_value <- numeric(n_var)

  overall_gst_num <- 0
  overall_gst_den <- 0
  n_gst_vars <- 0L
  overall_qst_num <- 0
  overall_qst_den <- 0
  n_qst_vars <- 0L

  for (k in seq_along(var_id)) {
    v <- var_id[k]
    entry <- precomputed[[v]]

    if (identical(entry$method, "Qst")) {
      res <- .fst_combine_qst(entry$summaries, group_names)
      if (!is.na(res$value)) {
        rng <- entry$rng
        if (!is.na(rng) && rng > 0) {
          overall_qst_num <- overall_qst_num + res$Vb / rng^2
          overall_qst_den <- overall_qst_den + (res$Vb + res$Vw) / rng^2
          n_qst_vars <- n_qst_vars + 1L
        }
      }
    } else {
      res <- .fst_combine_gst(entry$summaries, group_names)
      if (!is.na(res$value)) {
        overall_gst_num <- overall_gst_num + (res$Ht - res$Hs)
        overall_gst_den <- overall_gst_den + res$Ht
        n_gst_vars <- n_gst_vars + 1L
      }
    }

    out_type[k] <- entry$type
    out_method[k] <- entry$method
    out_n_groups[k] <- res$n_groups
    out_n_societies[k] <- res$n_societies
    out_value[k] <- res$value
  }

  overall_method <- character(0)
  overall_n_variables <- integer(0)
  overall_value <- numeric(0)
  if (n_gst_vars > 0) {
    overall_method <- c(overall_method, "Gst")
    overall_n_variables <- c(overall_n_variables, n_gst_vars)
    overall_value <- c(
      overall_value,
      if (overall_gst_den > 0) overall_gst_num / overall_gst_den else NA_real_
    )
  }
  if (n_qst_vars > 0) {
    overall_method <- c(overall_method, "Qst")
    overall_n_variables <- c(overall_n_variables, n_qst_vars)
    overall_value <- c(
      overall_value,
      if (overall_qst_den > 0) overall_qst_num / overall_qst_den else NA_real_
    )
  }

  list(
    type = out_type, method = out_method, n_groups = out_n_groups,
    n_societies = out_n_societies, value = out_value,
    overall_method = overall_method, overall_n_variables = overall_n_variables,
    overall_value = overall_value
  )
}
