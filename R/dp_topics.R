#' Browse D-PLACE variables by atomic topic
#'
#' A D-PLACE variable's `category` (see [dplace_variables]) is often several
#' topics joined together, e.g. `"Economy, Property, Subsistence"` -- which
#' is why an exact match like `category = "Subsistence"` in [dp_variables()]
#' misses most variables that mention it (see [contains()]). `dp_topics()`
#' splits every variable's `category` into its individual topics and returns
#' one row per variable/topic pair, so you can browse, count, or filter on a
#' single clean topic instead of the raw compound string.
#'
#' @details
#' # Untouched, not normalized
#' Topics are split and trimmed but not otherwise cleaned up -- if
#' D-PLACE's own `category` text has near-duplicate topics, both spellings
#' appear here as distinct topics rather than being merged. As of the
#' bundled snapshot this includes `"Labor"`/`"Labour"`,
#' `"Settlement"`/`"Settlements"`, `"Dwelling"`/`"Dwellings"`,
#' `"Wealth Transactions"`/`"Wealth transactions"`, and `"War"`/`"Warfare"`.
#' Run `sort(table(dp_topics()$topic), decreasing = TRUE)` to see the full
#' list of topics and how many variables carry each. [contains()] is often
#' the easiest way to combine near-duplicates yourself, since it's
#' case-insensitive by default -- `topic = contains("Wealth")` matches both
#' `"Wealth Transactions"` and `"Wealth transactions"` in one call.
#'
#' @param var_id Optional character vector of variable ID(s) to filter to.
#' @param topic Optional character vector of one or more topics to filter to
#'   (exact match against the split, trimmed topic), or [contains()] for a
#'   partial/regex match -- see Details.
#'
#' @return A tibble with one row per variable/topic pair: `var_id`,
#'   `var_name`, `topic`. A variable with no recorded `category` (currently
#'   one, in the bundled snapshot) doesn't appear.
#'
#' @examples
#' dp_topics(topic = "Subsistence")
#' dp_topics(topic = contains("Wealth")) # merges "Wealth Transactions"/"Wealth transactions"
#' sort(table(dp_topics()$topic), decreasing = TRUE) # topic counts, most first
#'
#' @export
dp_topics <- function(var_id = NULL, topic = NULL) {
  vars <- dplace_variables[!is.na(dplace_variables$category), c("var_id", "name", "category")]

  split_topics <- strsplit(vars$category, ",")
  n_topics <- lengths(split_topics)

  out <- data.frame(
    var_id = rep(vars$var_id, n_topics),
    var_name = rep(vars$name, n_topics),
    topic = trimws(unlist(split_topics)),
    stringsAsFactors = FALSE
  )

  if (!is.null(var_id)) {
    out <- out[out$var_id %in% var_id, , drop = FALSE]
  }
  if (!is.null(topic)) {
    out <- out[.gs_match_column(out$topic, topic, "topic"), , drop = FALSE]
  }

  tibble::as_tibble(out)
}
