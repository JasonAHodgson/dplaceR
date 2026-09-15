# --- internal helpers shared by dp_societies(), get_society(), and
# dp_variables() ------------------------------------------------------------

# Matches column `x` against `spec`: a plain character vector for an exact
# match (`x %in% spec`, NA-safe), or a contains() object (see ?contains) for
# a substring/regex match via grepl() against ANY of its patterns. grepl()
# already treats NA elements of `x` as non-matches, so no extra NA handling
# is needed for that branch.
.gs_match_column <- function(x, spec, arg_name) {
  if (inherits(spec, "dplaceR_contains")) {
    hits <- vapply(
      spec$pattern,
      function(p) grepl(p, x, ignore.case = spec$ignore.case, fixed = spec$fixed),
      logical(length(x))
    )
    rowSums(as.matrix(hits)) > 0
  } else {
    if (!is.character(spec)) {
      stop(
        "`", arg_name, "` must be a character vector for an exact match, ",
        "or contains(...) for a partial/regex match -- see ?contains.",
        call. = FALSE
      )
    }
    !is.na(x) & x %in% spec
  }
}

# Rejects a contains() object passed to an argument that doesn't support it
# -- rather than a confusing low-level error, or (worse) silently matching
# nothing.
.gs_reject_contains <- function(x, arg_name, reason) {
  if (inherits(x, "dplaceR_contains")) {
    stop("`", arg_name, "` doesn't support contains() -- ", reason, call. = FALSE)
  }
}
