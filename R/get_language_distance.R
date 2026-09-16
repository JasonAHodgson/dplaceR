#' Language (branch-length) distance from a point or society to a list of
#' societies
#'
#' Computes the linguistic distance from a single reference point -- either
#' an existing D-PLACE society or an arbitrary Glottocode -- to each society
#' in a list, as the branch-length ("patristic") distance between their
#' languages on a bundled D-PLACE language tree (see
#' [dp_trees()]/[dp_tree()]). For distances between all pairs within a set
#' of societies, use [get_pairwise_language_distance()] instead; it shares
#' this function's matching rules, units caveat, and `cross_tree`/
#' `multiplier` semantics.
#'
#' @details
#' See [get_pairwise_language_distance()] for full details on: how societies
#' are matched to tree tips (`glottocode`, falling back to
#' `language_level_glottocodes` when single-valued); the important caveat
#' that branch length units are NOT consistent across D-PLACE's bundled
#' trees (arbitrary Glottolog classification depth for most, real calibrated
#' dates for a minority -- check `dp_trees()`'s `source` column); and the
#' `cross_tree` options (`"na"`, implemented; `"join_root"`, not implemented
#' yet).
#'
#' @param point Either a single D-PLACE society ID (character, see
#'   [dp_societies()]), or a single Glottocode that appears in a bundled
#'   language tree (see [dp_trees()]) -- useful for referencing a language
#'   with no D-PLACE society attached.
#' @param soc_id Character vector of one or more D-PLACE society IDs to
#'   compute the distance to (see [dp_societies()]). Also accepts a data
#'   frame/tibble with a `soc_id` column, from which the column is used
#'   automatically. Unknown IDs, and societies whose language can't be
#'   matched to any bundled tree, are dropped with a warning.
#' @param cross_tree One of `"na"` or `"join_root"` -- see
#'   [get_pairwise_language_distance()]. There is no default; it must be
#'   supplied explicitly. `"join_root"` currently errors (not implemented
#'   yet).
#' @param multiplier Reserved for a future `cross_tree = "join_root"`
#'   implementation; currently unused. Default `2`.
#'
#' @return A tibble with one row per society in `soc_id` that has a
#'   matchable language: `soc_id` and `language_distance` (branch-length
#'   units of whichever tree the pair was computed on -- see the units
#'   caveat in [get_pairwise_language_distance()]). A society whose language
#'   is on a different tree from `point` gets `language_distance = NA` under
#'   `cross_tree = "na"`, with a warning summarizing how many such societies
#'   were found, rather than failing the whole call.
#'
#' @examples
#' \dontrun{
#' get_language_distance("B72", c("B73", "B79"), cross_tree = "na")
#' get_language_distance("naro1249", c("B72", "B73", "B79"), cross_tree = "na")
#' }
#'
#' @export
get_language_distance <- function(point, soc_id, cross_tree, multiplier = 2) {
  cross_tree <- .lang_dist_check_cross_tree(cross_tree)
  soc_id <- .gs_coerce_ids(soc_id, "soc_id", "soc_id")

  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }

  tip_index <- .lang_dist_build_tip_index()
  point_info <- .lang_dist_resolve_point(point, tip_index)

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_ids <- setdiff(soc_id, soc$soc_id)
  if (length(missing_ids) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_ids, collapse = ", "),
      call. = FALSE
    )
  }

  tip <- .lang_dist_resolve_tips(soc, tip_index)
  no_match <- is.na(tip)
  if (any(no_match)) {
    warning(
      "Dropping society(ies) whose language could not be matched to any ",
      "bundled tree (see ?get_language_distance for how matching works): ",
      paste(soc$soc_id[no_match], collapse = ", "),
      call. = FALSE
    )
    soc <- soc[!no_match, , drop = FALSE]
    tip <- tip[!no_match]
  }
  if (nrow(soc) < 1) {
    stop("No societies with a matchable language were found.", call. = FALSE)
  }

  tree_id <- unname(tip_index$tip_to_tree[tip])
  same_tree <- tree_id == point_info$tree_id

  language_distance <- rep(NA_real_, nrow(soc))

  if (any(same_tree)) {
    tr <- tip_index$tree_cache[[point_info$tree_id]]
    cop <- ape::cophenetic.phylo(tr)
    language_distance[same_tree] <- cop[cbind(point_info$tip, tip[same_tree])]
  }

  n_cross <- sum(!same_tree)
  if (n_cross > 0) {
    warning(
      n_cross, " society(ies) have a language on a different tree from ",
      "`point` (different language family/group) and are recorded as ",
      "`language_distance = NA` (cross_tree = \"na\").",
      call. = FALSE
    )
  }

  tibble::tibble(soc_id = soc$soc_id, language_distance = language_distance)
}
