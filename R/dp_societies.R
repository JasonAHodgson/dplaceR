#' Browse or filter D-PLACE societies
#'
#' @param glottocode Optional character vector of Glottocodes to filter to,
#'   or [contains()] for a partial/regex match.
#' @param region Optional character vector of regions to filter to (matched
#'   exactly against the `region` column; see
#'   `unique(dplace_societies$region)` for valid values), or [contains()]
#'   for a partial/regex match -- e.g. `region = contains("Africa")`, since
#'   D-PLACE splits Africa into several regions with no single `"Africa"`
#'   value.
#' @param soc_id Optional character vector of society IDs to filter to, or
#'   [contains()] for a partial/regex match. Also accepts a data
#'   frame/tibble with a `soc_id` column (e.g. an earlier `dp_societies()`
#'   result passed straight through), from which the column is used
#'   automatically.
#' @param xd_id Optional character vector of cross-dataset ID(s) to filter
#'   to, or [contains()] for a partial/regex match -- see
#'   [get_related_societies()] for finding a society's `xd_id` in the first
#'   place. Most societies have no `xd_id` (`NA`) and so never match.
#' @param lang_family Optional character vector of top-level language family
#'   name(s) to filter to (e.g. `"Indo-European"`, `"Austronesian"`), or
#'   [contains()] for a partial/regex match -- see [dp_lang_family_list()]
#'   for the full list of available families. An isolate (e.g. `"Zuni"`) is
#'   its own top-level family. Named `lang_family` (not plain `family`) to
#'   avoid clashing with D-PLACE's own "family" cultural/kinship variables,
#'   which mean something unrelated.
#' @param lang_family_id Optional character vector of top-level language
#'   family Glottocode(s) to filter to (e.g. `"indo1319"` for
#'   Indo-European), or [contains()] for a partial/regex match -- more
#'   stable than `lang_family` across any future family renaming.
#' @param type Character; which row types to include. Defaults to
#'   `"society"` (societies with coded cultural data). Use `NULL` to also
#'   include `"languoid"` rows (language varieties that appear only in a
#'   phylogeny, with no coded data of their own). Does not support
#'   [contains()].
#'
#' @return A tibble of societies, one row per society (see
#'   [dplace_societies] for column definitions).
#'
#' @examples
#' dp_societies(region = "Southern Africa")
#' dp_societies(region = contains("Africa"))
#' dp_societies(glottocode = "juho1239")
#' dp_societies(xd_id = "xd1") # !Kung, coded independently by 3 datasets
#' dp_societies(lang_family = "Indo-European")
#' dp_societies(lang_family = contains("Austro")) # Austronesian AND Austroasiatic
#'
#' @export
dp_societies <- function(glottocode = NULL, region = NULL, soc_id = NULL,
                          xd_id = NULL, lang_family = NULL,
                          lang_family_id = NULL, type = "society") {
  .gs_reject_contains(type, "type", "it only accepts \"society\"/\"languoid\"")
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")

  out <- dplace_societies

  if (!is.null(type)) {
    out <- out[out$type %in% type, , drop = FALSE]
  }
  if (!is.null(glottocode)) {
    out <- out[.gs_match_column(out$glottocode, glottocode, "glottocode"), , drop = FALSE]
  }
  if (!is.null(region)) {
    out <- out[.gs_match_column(out$region, region, "region"), , drop = FALSE]
  }
  if (!is.null(soc_id)) {
    out <- out[.gs_match_column(out$soc_id, soc_id, "soc_id"), , drop = FALSE]
  }
  if (!is.null(xd_id)) {
    out <- out[.gs_match_column(out$xd_id, xd_id, "xd_id"), , drop = FALSE]
  }
  if (!is.null(lang_family)) {
    out <- out[.gs_match_column(out$lang_family, lang_family, "lang_family"), , drop = FALSE]
  }
  if (!is.null(lang_family_id)) {
    out <- out[.gs_match_column(out$lang_family_id, lang_family_id, "lang_family_id"), , drop = FALSE]
  }

  tibble::as_tibble(out)
}
