#' Browse or filter D-PLACE societies
#'
#' @param glottocode Optional character vector of Glottocodes to filter to.
#' @param region Optional character vector of regions to filter to (matched
#'   exactly against the `region` column; see
#'   `unique(dplace_societies$region)` for valid values).
#' @param soc_id Optional character vector of society IDs to filter to.
#' @param type Character; which row types to include. Defaults to
#'   `"society"` (societies with coded cultural data). Use `NULL` to also
#'   include `"languoid"` rows (language varieties that appear only in a
#'   phylogeny, with no coded data of their own).
#'
#' @return A tibble of societies, one row per society (see
#'   [dplace_societies] for column definitions).
#'
#' @examples
#' dp_societies(region = "Southern Africa")
#' dp_societies(glottocode = "juho1239")
#'
#' @export
dp_societies <- function(glottocode = NULL, region = NULL, soc_id = NULL,
                          type = "society") {
  out <- dplace_societies

  if (!is.null(type)) {
    out <- out[out$type %in% type, , drop = FALSE]
  }
  if (!is.null(glottocode)) {
    out <- out[!is.na(out$glottocode) & out$glottocode %in% glottocode, , drop = FALSE]
  }
  if (!is.null(region)) {
    out <- out[!is.na(out$region) & out$region %in% region, , drop = FALSE]
  }
  if (!is.null(soc_id)) {
    out <- out[out$soc_id %in% soc_id, , drop = FALSE]
  }

  tibble::as_tibble(out)
}
