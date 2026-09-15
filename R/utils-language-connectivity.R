# --- internal helpers shared by get_language_distance() and ----------------
# --- get_pairwise_language_distance() (not exported) -----------------------

# Validates `cross_tree` and, for "join_root", stops immediately with an
# explanatory error -- that method isn't implemented yet (D-PLACE's bundled
# trees mix arbitrary Glottolog classification-depth branch lengths with
# real calibrated, year-scale branch lengths from published phylogenies, and
# joining trees with incompatible units needs more thought before it ships).
# Only "na" is currently usable; the check lives here so both functions fail
# the same way, with the same message, before doing any other work.
.lang_dist_check_cross_tree <- function(cross_tree) {
  if (missing(cross_tree) || length(cross_tree) == 0) {
    stop(
      "`cross_tree` must be supplied: one of \"na\" or \"join_root\" -- there ",
      "is no default. See ?get_language_distance or ",
      "?get_pairwise_language_distance for what each one means.",
      call. = FALSE
    )
  }
  cross_tree <- match.arg(cross_tree, c("na", "join_root"))
  if (cross_tree == "join_root") {
    stop(
      "cross_tree = \"join_root\" is not implemented yet. D-PLACE's bundled ",
      "trees mix arbitrary Glottolog classification-depth branch lengths ",
      "(most trees) with real calibrated, year-scale branch lengths from ",
      "published phylogenies (a minority) -- see the `source` column of ",
      "dp_trees() to tell which is which for a given tree. Joining two trees ",
      "whose branch lengths might not be on the same scale needs more thought ",
      "before it ships as a real feature. Only cross_tree = \"na\" is ",
      "currently supported.",
      call. = FALSE
    )
  }
  cross_tree
}

# Scans every bundled tree once and returns:
#  - tip_to_tree: a named character vector, tip Glottocode -> tree_id
#  - tree_cache: a named list, tree_id -> the already-parsed "phylo" object,
#    so callers never have to re-parse (via dp_tree()) a tree they've
#    already loaded here.
# Every tip Glottocode across the whole bundled tree collection is unique to
# a single tree_id (confirmed empirically against the bundled data), so this
# mapping is never ambiguous.
.lang_dist_build_tip_index <- function() {
  if (!requireNamespace("ape", quietly = TRUE)) {
    stop(
      "Computing language distances requires the 'ape' package. Install it ",
      "with install.packages(\"ape\").",
      call. = FALSE
    )
  }
  trees <- dp_trees()
  tree_cache <- vector("list", nrow(trees))
  names(tree_cache) <- trees$tree_id
  tip_to_tree <- character(0)
  for (tid in trees$tree_id) {
    tr <- dp_tree(tid)
    tree_cache[[tid]] <- tr
    tip_to_tree[tr$tip.label] <- tid
  }
  list(tip_to_tree = tip_to_tree, tree_cache = tree_cache)
}

# Resolves each society in `soc` (a tibble with `glottocode` and
# `language_level_glottocodes` columns, as returned by dp_societies()) to a
# tip Glottocode present in `tip_index$tip_to_tree`:
#  - `glottocode` is tried first (it's always a single value).
#  - `language_level_glottocodes` is tried as a fallback, but only when it
#    names a SINGLE Glottocode -- a handful of societies (around 2% of those
#    with a non-missing value) have it as a space-separated list covering
#    several dialects/varieties, and there's no principled way to pick one
#    tip out of those on the society's behalf, so they're left unresolved.
# NA where neither resolves.
.lang_dist_resolve_tips <- function(soc, tip_index) {
  tip <- rep(NA_character_, nrow(soc))

  has_gc <- !is.na(soc$glottocode) & soc$glottocode %in% names(tip_index$tip_to_tree)
  tip[has_gc] <- soc$glottocode[has_gc]

  need_fallback <- is.na(tip) & !is.na(soc$language_level_glottocodes) &
    !grepl(" ", soc$language_level_glottocodes, fixed = TRUE)
  llg <- soc$language_level_glottocodes[need_fallback]
  has_llg <- llg %in% names(tip_index$tip_to_tree)
  tip[need_fallback][has_llg] <- llg[has_llg]

  tip
}

# Resolves `point` (a single D-PLACE society ID, or a bare Glottocode) to a
# list(tip, tree_id).
.lang_dist_resolve_point <- function(point, tip_index) {
  if (!is.character(point) || length(point) != 1) {
    stop(
      "`point` must be either a single D-PLACE society ID (character), or a ",
      "single Glottocode that appears in a bundled language tree (see ",
      "dp_trees()).",
      call. = FALSE
    )
  }

  soc <- dp_societies(soc_id = point, type = NULL)
  if (nrow(soc) == 1) {
    tip <- .lang_dist_resolve_tips(soc, tip_index)
    if (is.na(tip)) {
      stop(
        "`point` society '", point, "' has no language classification ",
        "(glottocode) matching any bundled tree.",
        call. = FALSE
      )
    }
    return(list(tip = tip, tree_id = unname(tip_index$tip_to_tree[tip])))
  }

  if (point %in% names(tip_index$tip_to_tree)) {
    return(list(tip = point, tree_id = unname(tip_index$tip_to_tree[point])))
  }

  stop(
    "`point` must be either a single D-PLACE society ID (see dp_societies()), ",
    "or a Glottocode that appears in a bundled language tree (see ",
    "dp_trees()); '", point, "' matched neither.",
    call. = FALSE
  )
}
