#' List every language family represented among coded societies
#'
#' A quick way to see what's available before filtering
#' [dp_societies()]/[get_society()]'s `lang_family`/`lang_family_id` --
#' equivalent to `sort(unique(dp_societies()$lang_family))`, but without
#' building the full society table yourself. Only considers
#' `type = "society"` rows (societies with coded cultural data) -- see
#' [dp_societies()]'s `type` argument.
#'
#' @return A sorted character vector of every distinct top-level language
#'   family name (see [dplace_societies]'s `lang_family`/`lang_family_id`
#'   columns for how families are derived, including the note on isolates
#'   being their own top-level family).
#'
#' @examples
#' dp_lang_family_list()
#'
#' @export
dp_lang_family_list <- function() {
  sort(unique(dp_societies()$lang_family))
}
