# Internal helpers shared by the variable-aware plotting functions
# (plot_variable_map() and plot_variable_time()): validating `soc_id`/
# `var_id`, and turning a D-PLACE variable's raw dp_values() rows into a
# single typed, per-society value ready to colour a plot by. Kept here so
# the two plotting functions can't drift apart on this logic (e.g. the
# missing-data sentinel exclusion, or an Ordinal variable's colour-scale
# level order).

.pvm_validate_soc_id <- function(soc_id) {
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")
  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }
  soc_id <- unique(soc_id)

  soc <- dp_societies(soc_id = soc_id)
  missing_soc <- setdiff(soc_id, soc$soc_id)
  if (length(missing_soc) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_soc, collapse = ", "),
      call. = FALSE
    )
  }
  if (nrow(soc) < 1) {
    stop("None of the requested society IDs were found.", call. = FALSE)
  }
  soc
}

.pvm_validate_var_id <- function(var_id, fn_name) {
  var_id <- .gs_coerce_ids(var_id, "var_id", "var_id")
  if (length(var_id) != 1) {
    stop(
      "`var_id` must be a single variable ID -- ", fn_name, "() plots one ",
      "variable at a time; call it again for another.",
      call. = FALSE
    )
  }
  var_meta <- dp_variables(var_id = var_id)
  if (nrow(var_meta) < 1) {
    stop(
      "Variable '", var_id, "' not found; see dp_variables() to browse what's available.",
      call. = FALSE
    )
  }
  var_meta
}

# `soc_id` here should already be the validated/deduplicated vector from
# .pvm_validate_soc_id(); returns a tibble(soc_id, .pvm_value) with exactly
# one row per input soc_id (after any drop_na filtering).
.pvm_coded_values <- function(soc_id, var_id, var_type, drop_na) {
  vals <- dp_values(var_id = var_id, soc_id = soc_id)
  vals <- .cult_dist_drop_missing_sentinel(vals)
  vals <- .cult_dist_collapse_duplicates(vals)

  codes <- dplace_codes[dplace_codes$var_id == var_id, c("code_id", "name", "ord")]
  names(codes)[names(codes) == "name"] <- "code_label"

  vals <- merge(vals[, c("soc_id", "value", "code_id")], codes, by = "code_id", all.x = TRUE, sort = FALSE)

  out <- merge(
    tibble::tibble(soc_id = soc_id), vals[, c("soc_id", "value", "code_label", "ord")],
    by = "soc_id", all.x = TRUE, sort = FALSE
  )

  is_continuous <- !is.na(var_type) && var_type == "Continuous"
  if (is_continuous) {
    out$.pvm_value <- suppressWarnings(as.numeric(out$value))
  } else {
    out$.pvm_value <- out$code_label
    if (!is.na(var_type) && var_type == "Ordinal") {
      # exclude the missing-data sentinel code from the level set itself --
      # not just from the data -- so it can't appear as a (nonsensical)
      # highest-ranked ordinal level
      codes_real <- codes[!.cult_dist_is_missing_sentinel(codes$code_id), , drop = FALSE]
      lvl <- unique(codes_real$code_label[order(codes_real$ord)])
      out$.pvm_value <- factor(out$.pvm_value, levels = lvl, ordered = TRUE)
    }
  }

  n_missing <- sum(is.na(out$.pvm_value))
  if (n_missing > 0) {
    if (isTRUE(drop_na)) {
      warning(
        n_missing, " society(ies) dropped: no usable coded value for '", var_id,
        "' (either uncoded, or only D-PLACE's missing-data sentinel). Pass ",
        "drop_na = FALSE to keep and show them as NA instead.",
        call. = FALSE
      )
      out <- out[!is.na(out$.pvm_value), , drop = FALSE]
    } else {
      warning(
        n_missing, " society(ies) have no usable coded value for '", var_id,
        "' and will show as NA.",
        call. = FALSE
      )
    }
  }
  if (nrow(out) < 1) {
    stop("No societies with a usable coded value for '", var_id, "' remain to plot.", call. = FALSE)
  }

  out[, c("soc_id", ".pvm_value")]
}
