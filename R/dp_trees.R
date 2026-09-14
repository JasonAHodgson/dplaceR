#' Browse D-PLACE language phylogenies
#'
#' Lists the phylogenetic/classification trees available in D-PLACE. Use
#' [dp_tree()] to load a specific tree.
#'
#' @param tree_id Optional character vector of tree IDs to filter to
#'   (usually Glottocodes identifying a language family/group).
#' @param contribution_id Optional character vector of contribution IDs to
#'   filter to (e.g. `"glottolog_glottolog"`).
#'
#' @return A tibble of tree metadata (see [dplace_trees] for column
#'   definitions), excluding the `nexus` column so it stays easy to browse
#'   -- use [dp_tree()] to get the actual tree.
#'
#' @examples
#' dp_trees()
#'
#' @export
dp_trees <- function(tree_id = NULL, contribution_id = NULL) {
  out <- dplace_trees

  if (!is.null(tree_id)) {
    out <- out[out$tree_id %in% tree_id, , drop = FALSE]
  }
  if (!is.null(contribution_id)) {
    out <- out[!is.na(out$contribution_id) & out$contribution_id %in% contribution_id, , drop = FALSE]
  }

  out <- out[, setdiff(names(out), "nexus"), drop = FALSE]
  tibble::as_tibble(out)
}
