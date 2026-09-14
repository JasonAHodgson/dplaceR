#' Browse D-PLACE dataset contributions (sources)
#'
#' @param contribution_id Optional character vector of contribution IDs to
#'   filter to.
#' @param type Optional character vector restricting to contribution
#'   type(s), e.g. `"dataset"` or `"phylogeny"`.
#'
#' @return A tibble of contributions (see [dplace_contributions] for column
#'   definitions).
#'
#' @examples
#' dp_contributions(type = "dataset")
#'
#' @export
dp_contributions <- function(contribution_id = NULL, type = NULL) {
  out <- dplace_contributions

  if (!is.null(contribution_id)) {
    out <- out[out$contribution_id %in% contribution_id, , drop = FALSE]
  }
  if (!is.null(type)) {
    out <- out[!is.na(out$type) & out$type %in% type, , drop = FALSE]
  }

  tibble::as_tibble(out)
}
