#' Count how many coded societies belong to each language family
#'
#' A two-column summary of [dp_lang_family_list()]: how many
#' `type = "society"` rows (see [dp_societies()]) belong to each top-level
#' language family, so you can see at a glance which families are well
#' represented before filtering by one.
#'
#' @return A tibble with one row per family, in the same order as
#'   [dp_lang_family_list()]: `lang_family` and `n_societies` (the number of
#'   coded societies belonging to that top-level family -- see
#'   [dplace_societies]'s `lang_family`/`lang_family_id` columns).
#'   Societies with no `lang_family` (no `glottocode`) aren't counted
#'   anywhere in this table, so `sum(dp_lang_family_table()$n_societies)`
#'   can be slightly less than `nrow(dp_societies())`.
#'
#' @examples
#' dp_lang_family_table()
#' # most represented families first
#' dp_lang_family_table()[order(-dp_lang_family_table()$n_societies), ]
#'
#' @export
dp_lang_family_table <- function() {
  families <- dp_lang_family_list()
  counts <- table(dp_societies()$lang_family)

  tibble::tibble(
    lang_family = families,
    n_societies = as.integer(counts[families])
  )
}
