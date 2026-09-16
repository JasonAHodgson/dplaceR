#' Plot a distance tree from a pairwise distance table
#'
#' Builds and plots a distance-based tree (neighbor-joining or UPGMA) from
#' any of this package's pairwise distance/differentiation tables --
#' [get_pairwise_geo_distance()], [get_pairwise_cult_distance()],
#' [get_pairwise_language_distance()] (all keyed by `soc_id_1`/`soc_id_2`),
#' or [get_pairwise_cultural_FST()]'s `overall`/`by_variable` tibbles
#' (keyed by `group_1`/`group_2`) -- or any data frame following the same
#' convention.
#'
#' @param pairwise A data frame/tibble with one row per unique pair: two
#'   node-ID columns (auto-detected as `soc_id_1`/`soc_id_2` or
#'   `group_1`/`group_2`; see `id_cols`) and a numeric distance column (see
#'   `distance_col`).
#' @param distance_col Optional; the name of the numeric column in
#'   `pairwise` to use as the distance. If `NULL` (the default), used only
#'   when exactly one non-ID numeric column is present -- otherwise, name
#'   it explicitly (e.g. `"value"` for [get_pairwise_cultural_FST()]'s
#'   tables, which also carry `n_variables`/`n_groups`).
#' @param id_cols Optional length-2 character vector naming the two node-ID
#'   columns, for a `pairwise` table that doesn't follow the
#'   `soc_id_1`/`soc_id_2` or `group_1`/`group_2` convention. If `NULL`
#'   (the default), auto-detected.
#' @param method Tree-building method: `"nj"` (neighbor-joining, via
#'   [ape::nj()] -- the default, and the usual choice for a distance
#'   matrix that isn't guaranteed ultrametric) or `"upgma"` (average-linkage
#'   clustering, via `stats::hclust(method = "average")` -- assumes a
#'   roughly clock-like/ultrametric distance and produces an
#'   already-rooted tree).
#' @param root Rooting applied to the resulting tree: `"none"` (the
#'   default -- left exactly as `method` produces it: genuinely unrooted
#'   for `"nj"`, or rooted at its last merge for `"upgma"`), `"midpoint"`
#'   (root at the midpoint of the tree's longest tip-to-tip path, via
#'   [phangorn::midpoint()] -- a reasonable default when no natural
#'   outgroup is available, but see its documentation for the assumptions
#'   this makes), or `"outgroup"` (root using `outgroup`).
#' @param outgroup One or more node IDs (matching whichever ID column
#'   `pairwise` uses) to root on, when `root = "outgroup"`. Ignored (with a
#'   warning) for any other `root`.
#' @param on_missing What to do if `pairwise` has missing (`NA`) distances
#'   for some pair(s) -- as e.g. [get_pairwise_geo_distance()] records for
#'   societies with no land route, or [get_pairwise_language_distance()]
#'   for languages on different trees. `"drop"` (the default) repeatedly
#'   excludes whichever node is involved in the most remaining missing
#'   distances until none are left, with a warning listing what was
#'   dropped (erroring if fewer than 3 nodes would remain); `"error"`
#'   stops immediately instead, naming the affected nodes.
#' @param tip_label For a `soc_id_1`/`soc_id_2`-keyed `pairwise`: `"id"`
#'   (the default) labels tips with the raw `soc_id`, `"name"` looks up
#'   and uses each society's name instead (via [dp_societies()],
#'   disambiguating with the `soc_id` in parentheses if any names collide).
#'   Ignored (with a warning) for a `group_1`/`group_2`-keyed `pairwise`,
#'   where there's no name to look up.
#' @param ... Further arguments passed to [ape::plot.phylo()] (e.g.
#'   `type = "fan"`, `cex`, `tip.color`), overriding this function's
#'   defaults (`type = "unrooted"` when `root = "none"`, `"phylogram"`
#'   otherwise).
#'
#' @return Invisibly, the `"phylo"` tree object (from ape) that was
#'   plotted -- capture it to inspect further, re-plot with different
#'   [ape::plot.phylo()] options, or save it (e.g.
#'   `ape::write.tree(tree, "tree.nwk")`).
#'
#' @examples
#' \dontrun{
#' d <- get_pairwise_geo_distance(
#'   dp_societies(region = "Southern Africa")$soc_id, method = "great_circle"
#' )
#' plot_distance_tree(d, root = "midpoint")
#' plot_distance_tree(d, root = "outgroup", outgroup = "B72")
#'
#' fst <- get_pairwise_cultural_FST(
#'   dp_societies(lang_family = c("Indo-European", "Afro-Asiatic", "Austronesian"))$soc_id,
#'   group = "lang_family", category = contains("Subsistence")
#' )
#' plot_distance_tree(fst$overall, distance_col = "value", method = "upgma")
#' }
#'
#' @export
plot_distance_tree <- function(pairwise, distance_col = NULL, id_cols = NULL,
                                method = c("nj", "upgma"),
                                root = c("none", "midpoint", "outgroup"),
                                outgroup = NULL,
                                on_missing = c("drop", "error"),
                                tip_label = c("id", "name"),
                                ...) {
  method <- match.arg(method)
  root <- match.arg(root)
  on_missing <- match.arg(on_missing)
  tip_label <- match.arg(tip_label)

  if (!requireNamespace("ape", quietly = TRUE)) {
    stop(
      "plot_distance_tree() requires the 'ape' package. Install it with ",
      "install.packages(\"ape\").",
      call. = FALSE
    )
  }
  if (!is.data.frame(pairwise)) {
    stop(
      "`pairwise` must be a data frame/tibble, e.g. get_pairwise_geo_distance()'s output.",
      call. = FALSE
    )
  }

  # --- identify the two node-ID columns ------------------------------------
  known_id_pairs <- list(c("soc_id_1", "soc_id_2"), c("group_1", "group_2"))
  if (is.null(id_cols)) {
    found <- Filter(function(p) all(p %in% names(pairwise)), known_id_pairs)
    if (length(found) == 0) {
      stop(
        "Couldn't find a pair of node-ID columns in `pairwise` (looked for ",
        paste(vapply(known_id_pairs, paste, character(1), collapse = "/"), collapse = ", "),
        "). Pass `id_cols = c(<col1>, <col2>)` explicitly.",
        call. = FALSE
      )
    }
    id_cols <- found[[1]]
  } else {
    if (length(id_cols) != 2 || !all(id_cols %in% names(pairwise))) {
      stop("`id_cols` must name two existing columns in `pairwise`.", call. = FALSE)
    }
  }
  id_type <- if (identical(id_cols, c("soc_id_1", "soc_id_2"))) "soc_id" else "node"

  # --- identify the distance column ----------------------------------------
  if (is.null(distance_col)) {
    candidates <- setdiff(names(pairwise), id_cols)
    numeric_candidates <- candidates[vapply(pairwise[candidates], is.numeric, logical(1))]
    if (length(numeric_candidates) != 1) {
      stop(
        "Couldn't auto-detect a single numeric distance column in `pairwise` (candidate(s): ",
        if (length(numeric_candidates) == 0) "none" else paste(numeric_candidates, collapse = ", "),
        "). Pass `distance_col` explicitly.",
        call. = FALSE
      )
    }
    distance_col <- numeric_candidates
  } else if (!distance_col %in% names(pairwise)) {
    stop("`distance_col` '", distance_col, "' not found in `pairwise`.", call. = FALSE)
  }

  id1 <- as.character(pairwise[[id_cols[1]]])
  id2 <- as.character(pairwise[[id_cols[2]]])
  dist_val <- pairwise[[distance_col]]
  if (!is.numeric(dist_val)) {
    stop("`distance_col` ('", distance_col, "') must be numeric.", call. = FALSE)
  }
  if (any(id1 == id2)) {
    stop(
      "`pairwise` contains self-pair row(s) (", id_cols[1], " == ", id_cols[2],
      "); expected one row per unique pair of distinct nodes.",
      call. = FALSE
    )
  }

  tips <- sort(unique(c(id1, id2)))
  if (length(tips) < 3) {
    stop("Need at least 3 distinct ", id_type, "s to build a tree; found ", length(tips), ".", call. = FALSE)
  }

  # --- build the (symmetric) distance matrix -------------------------------
  key <- paste(pmin(id1, id2), pmax(id1, id2), sep = "\r")
  if (anyDuplicated(key)) {
    stop(
      sum(duplicated(key)), " pair(s) appear more than once in `pairwise` -- expected one row ",
      "per unique pair.",
      call. = FALSE
    )
  }
  if (any(dist_val < 0, na.rm = TRUE)) {
    warning(
      "`", distance_col, "` contains negative value(s) -- distance-based tree methods can ",
      "produce negative branch lengths from these; treat the tree topology with extra caution.",
      call. = FALSE
    )
  }

  mat <- matrix(NA_real_, nrow = length(tips), ncol = length(tips), dimnames = list(tips, tips))
  diag(mat) <- 0
  idx <- cbind(match(id1, tips), match(id2, tips))
  mat[idx] <- dist_val
  mat[idx[, c(2, 1), drop = FALSE]] <- dist_val

  # --- handle missing (NA) pairwise distances ------------------------------
  na_mask <- is.na(mat)
  diag(na_mask) <- FALSE
  if (any(na_mask)) {
    if (on_missing == "error") {
      missing_ids <- tips[rowSums(na_mask) > 0]
      stop(
        "`pairwise` has missing (NA) distance(s) involving: ", paste(missing_ids, collapse = ", "),
        ". Pass on_missing = \"drop\" to automatically exclude as few nodes as possible, or ",
        "filter `pairwise` (or your original soc_id list) yourself.",
        call. = FALSE
      )
    }
    dropped <- character(0)
    keep <- tips
    repeat {
      sub_na <- is.na(mat[keep, keep, drop = FALSE])
      diag(sub_na) <- FALSE
      if (!any(sub_na)) break
      worst <- names(which.max(rowSums(sub_na)))
      dropped <- c(dropped, worst)
      keep <- setdiff(keep, worst)
      if (length(keep) < 3) {
        stop(
          "Too many missing distances in `pairwise` -- fewer than 3 ", id_type, "s would remain ",
          "after dropping incomplete ones (already dropped: ", paste(dropped, collapse = ", "), ").",
          call. = FALSE
        )
      }
    }
    warning(
      length(dropped), " ", id_type, "(s) dropped (missing distance to at least one other): ",
      paste(dropped, collapse = ", "),
      call. = FALSE
    )
    mat <- mat[keep, keep, drop = FALSE]
    tips <- keep
  }

  # --- build the tree -------------------------------------------------------
  d <- stats::as.dist(mat)
  tree <- switch(
    method,
    nj = ape::nj(d),
    upgma = ape::as.phylo(stats::hclust(d, method = "average"))
  )

  # --- rooting ---------------------------------------------------------------
  if (!is.null(outgroup) && root != "outgroup") {
    warning("`outgroup` supplied but ignored since root != \"outgroup\".", call. = FALSE)
  }
  if (root == "outgroup") {
    if (is.null(outgroup)) {
      stop("root = \"outgroup\" requires `outgroup` (one or more node IDs).", call. = FALSE)
    }
    outgroup <- as.character(outgroup)
    missing_og <- setdiff(outgroup, tree$tip.label)
    if (length(missing_og) > 0) {
      stop(
        "`outgroup` ID(s) not found among the tree's tips (were they dropped due to missing ",
        "distances?): ", paste(missing_og, collapse = ", "),
        call. = FALSE
      )
    }
    if (length(outgroup) >= length(tree$tip.label)) {
      stop("`outgroup` must not include all tips.", call. = FALSE)
    }
    tree <- ape::root(tree, outgroup = outgroup, resolve.root = TRUE)
  } else if (root == "midpoint") {
    if (!requireNamespace("phangorn", quietly = TRUE)) {
      stop(
        "root = \"midpoint\" requires the 'phangorn' package. Install it with ",
        "install.packages(\"phangorn\").",
        call. = FALSE
      )
    }
    tree <- phangorn::midpoint(tree)
  }

  # --- tip labels -------------------------------------------------------------
  if (tip_label == "name") {
    if (id_type == "soc_id") {
      meta <- dp_societies(soc_id = tree$tip.label, type = NULL)
      name_lookup <- stats::setNames(meta$name, meta$soc_id)
      new_labels <- unname(name_lookup[tree$tip.label])
      unmatched <- is.na(new_labels)
      new_labels[unmatched] <- tree$tip.label[unmatched]
      dupes <- new_labels[duplicated(new_labels) | duplicated(new_labels, fromLast = TRUE)]
      is_dupe <- new_labels %in% unique(dupes)
      new_labels[is_dupe] <- paste0(new_labels[is_dupe], " (", tree$tip.label[is_dupe], ")")
      tree$tip.label <- new_labels
    } else {
      warning(
        "tip_label = \"name\" only applies to a soc_id-keyed `pairwise`; ignored.",
        call. = FALSE
      )
    }
  }

  # --- plot --------------------------------------------------------------------
  default_type <- if (root == "none") "unrooted" else "phylogram"
  plot_args <- utils::modifyList(list(x = tree, type = default_type), list(...))
  do.call(ape::plot.phylo, plot_args)

  invisible(tree)
}
