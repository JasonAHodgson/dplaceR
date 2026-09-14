#' Load a D-PLACE language phylogeny
#'
#' @param tree_id A single tree ID (see [dp_trees()]).
#' @param raw Logical; if `TRUE`, return the raw NEXUS text instead of a
#'   parsed tree. Useful if you don't have the ape package installed, or
#'   want to parse the tree yourself.
#'
#' @return If `raw = FALSE` (the default), an object of class `"phylo"`
#'   (from the ape package), with tip labels given as Glottocodes. If
#'   `raw = TRUE`, a single character string of NEXUS-format tree data.
#'
#' @examples
#' \donttest{
#' tr <- dp_tree("abkh1242")
#' if (requireNamespace("ape", quietly = TRUE)) {
#'   ape::plot.phylo(tr)
#' }
#' }
#'
#' @export
dp_tree <- function(tree_id, raw = FALSE) {
  if (length(tree_id) != 1) {
    stop("`tree_id` must be a single tree ID; see dp_trees().", call. = FALSE)
  }

  row <- dplace_trees[dplace_trees$tree_id == tree_id, , drop = FALSE]
  if (nrow(row) == 0) {
    stop("No tree found with tree_id '", tree_id, "'; see dp_trees().", call. = FALSE)
  }

  nexus_text <- row$nexus[[1]]
  if (is.na(nexus_text)) {
    stop("Tree '", tree_id, "' has no tree data available.", call. = FALSE)
  }

  if (isTRUE(raw)) {
    return(nexus_text)
  }

  if (!requireNamespace("ape", quietly = TRUE)) {
    stop(
      "Reading a tree requires the 'ape' package. Install it with ",
      "install.packages(\"ape\"), or use dp_tree(tree_id, raw = TRUE) to get ",
      "the raw NEXUS text instead.",
      call. = FALSE
    )
  }

  tmp <- tempfile(fileext = ".nex")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(nexus_text, tmp)
  ape::read.nexus(tmp)
}
