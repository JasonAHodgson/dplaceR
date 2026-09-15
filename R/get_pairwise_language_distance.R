#' Pairwise language (branch-length) distance between societies
#'
#' Computes the pairwise linguistic distance between D-PLACE societies as
#' the branch-length ("patristic") distance between their languages on a
#' bundled D-PLACE language tree (see [dp_trees()]/[dp_tree()]): the sum of
#' branch lengths along the path connecting the two languages' tips. See
#' [get_language_distance()] for the same measure applied to a single
#' reference point vs. a list of societies rather than all pairs within one
#' list.
#'
#' @details
#' # Matching societies to tree tips
#' Each society is matched to a tip by its `glottocode` (tried first, and
#' always a single value when present -- see [dp_societies()]), falling back
#' to its `language_level_glottocodes` when that names a single Glottocode.
#' A small number of societies (around 2% of those with a non-missing
#' `language_level_glottocodes`) have it as a space-separated list covering
#' several dialects/varieties at once; those are left unmatched rather than
#' guessing which single tip to use. Societies that don't resolve to a tip
#' in any bundled tree at all (roughly a third of D-PLACE societies, mostly
#' for lack of a usable Glottocode) are dropped with a warning.
#'
#' # Branch length units are NOT consistent across trees
#' This is the important caveat: D-PLACE's 114 bundled trees come from two
#' very different sources, and their branch lengths are not on the same
#' scale. 85 are Glottolog's own family classification trees, whose branch
#' lengths are small arbitrary integers (mostly 1-3) reflecting
#' classification depth, not time or any other physical quantity. The
#' remaining ~29 are real, independently published, dated phylogenies (e.g.
#' Bayesian-dated language trees), whose branch lengths are on the order of
#' hundreds to thousands (most plausibly years, though this isn't recorded
#' in the data -- `dp_trees()`'s `branch_length_unit` column is `NA` for
#' every bundled tree). Check `dp_trees()`'s `source` column (`
#' "glottolog_glottolog"` vs a `"dplace-phylogeny-*"` value) for which kind
#' produced a given result before treating two distances as comparable,
#' especially when they come from different trees.
#'
#' # Cross-tree pairs (`cross_tree`)
#' A pair of societies whose languages resolve to tips on two different
#' trees (different language families/groups) has no path connecting them
#' at all -- `cross_tree` controls what happens then, and there is
#' deliberately no default, so every call has to say which one it means:
#' \describe{
#'   \item{`"na"`}{Records `NA` for that pair, with a warning summarizing how
#'     many such pairs were found -- the honest option, given the units
#'     caveat above: there's no way to make up a meaningful cross-family
#'     distance without picking some convention for how "far apart" two
#'     unrelated language families are, and (per that caveat) even the trees
#'     you'd want to compare might not share a scale to begin with.}
#'   \item{`"join_root"`}{**Not implemented yet.** The plan is to treat the
#'     two languages' trees as if grafted onto a shared root -- distance =
#'     (root-to-tip depth of language 1) + (root-to-tip depth of language 2)
#'     + `multiplier` * (the larger of the two trees' own maximum
#'     root-to-tip depths) -- but given the units caveat above, that
#'     "biggest root-to-tip depth" can mean wildly different things
#'     depending on which two trees are involved, and this needs more
#'     thought before it ships. Calling with `cross_tree = "join_root"`
#'     currently just errors, explaining this.}
#' }
#'
#' @param soc_id Character vector of two or more D-PLACE society IDs (see
#'   [dp_societies()]). Unknown IDs are dropped with a warning.
#' @param cross_tree One of `"na"` or `"join_root"` -- see Details. There is
#'   no default; it must be supplied explicitly. `"join_root"` currently
#'   errors (not implemented yet).
#' @param multiplier Reserved for the future `cross_tree = "join_root"`
#'   implementation described in Details; currently unused. Default `2`.
#'
#' @return A tibble with one row per unique pair of the input societies:
#'   `soc_id_1`, `soc_id_2`, and `language_distance` (branch-length units of
#'   whichever tree the pair was computed on -- see the units caveat in
#'   Details). A pair whose languages are on different trees gets
#'   `language_distance = NA` under `cross_tree = "na"`, with a warning
#'   summarizing how many such pairs were found, rather than failing the
#'   whole call.
#'
#' @examples
#' \dontrun{
#' get_pairwise_language_distance(c("B72", "B73", "B79"), cross_tree = "na")
#' }
#'
#' @export
get_pairwise_language_distance <- function(soc_id, cross_tree, multiplier = 2) {
  cross_tree <- .lang_dist_check_cross_tree(cross_tree)

  if (length(soc_id) < 2) {
    stop("`soc_id` must contain at least two society IDs.", call. = FALSE)
  }
  if (anyDuplicated(soc_id)) {
    stop("`soc_id` contains duplicate values.", call. = FALSE)
  }

  soc <- dp_societies(soc_id = soc_id, type = NULL)
  missing_ids <- setdiff(soc_id, soc$soc_id)
  if (length(missing_ids) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_ids, collapse = ", "),
      call. = FALSE
    )
  }

  tip_index <- .lang_dist_build_tip_index()
  tip <- .lang_dist_resolve_tips(soc, tip_index)
  no_match <- is.na(tip)
  if (any(no_match)) {
    warning(
      "Dropping society(ies) whose language could not be matched to any ",
      "bundled tree (see ?get_pairwise_language_distance for how matching ",
      "works): ", paste(soc$soc_id[no_match], collapse = ", "),
      call. = FALSE
    )
    soc <- soc[!no_match, , drop = FALSE]
    tip <- tip[!no_match]
  }
  if (nrow(soc) < 2) {
    stop("Fewer than two societies with a matchable language remain.", call. = FALSE)
  }

  tree_id <- unname(tip_index$tip_to_tree[tip])

  pairs_idx <- utils::combn(nrow(soc), 2)
  same_tree <- tree_id[pairs_idx[1, ]] == tree_id[pairs_idx[2, ]]

  d <- rep(NA_real_, ncol(pairs_idx))
  pair_key <- paste(pairs_idx[1, ], pairs_idx[2, ])

  groups <- split(seq_len(nrow(soc)), tree_id)
  for (grp_idx in groups) {
    if (length(grp_idx) < 2) next # only one society on this tree -- nothing to pair within it

    tr <- tip_index$tree_cache[[tree_id[grp_idx[1]]]]
    cop <- ape::cophenetic.phylo(tr)

    grp_pairs <- utils::combn(seq_along(grp_idx), 2)
    grp_tips_1 <- tip[grp_idx[grp_pairs[1, ]]]
    grp_tips_2 <- tip[grp_idx[grp_pairs[2, ]]]
    grp_d <- cop[cbind(grp_tips_1, grp_tips_2)]

    global_i <- grp_idx[grp_pairs[1, ]]
    global_j <- grp_idx[grp_pairs[2, ]]
    pos <- match(paste(global_i, global_j), pair_key)
    d[pos] <- grp_d
  }

  n_cross <- sum(!same_tree)
  if (n_cross > 0) {
    warning(
      n_cross, " pair(s) of societies have languages on different trees ",
      "(different language families/groups) and are recorded as ",
      "`language_distance = NA` (cross_tree = \"na\").",
      call. = FALSE
    )
  }

  tibble::tibble(
    soc_id_1 = soc$soc_id[pairs_idx[1, ]],
    soc_id_2 = soc$soc_id[pairs_idx[2, ]],
    language_distance = d
  )
}
