#' Pairwise geographic distance between societies (land-route)
#'
#' Computes the pairwise geographic distance between D-PLACE societies using
#' the graph-based least-cost path method implemented in the 'geoGraph'
#' package (Andrea Manica's group,
#' \url{https://github.com/EvolEcolGroup/geograph}). Rather than a simple
#' great-circle distance, geoGraph routes paths across a global grid with
#' sea-crossing edges removed, so the result approximates the distance a
#' person would have to travel over land -- the "least-cost"/"waypoint"
#' approach commonly used in human population genetics and cross-cultural
#' research to model the geographic distance underlying patterns of
#' genetic and cultural differentiation.
#'
#' 'geoGraph' is not on CRAN and is a Suggested, not required, dependency of
#' dplaceR -- this function is only usable once it (and its own
#' dependencies) are installed. Install it with:
#' \preformatted{
#' # geoGraph depends on the Bioconductor packages 'graph' and 'RBGL'
#' if (!requireNamespace("BiocManager", quietly = TRUE)) {
#'   install.packages("BiocManager")
#' }
#' BiocManager::install(c("graph", "RBGL"))
#'
#' install.packages("pak")
#' pak::pak("EvolEcolGroup/geograph")
#' }
#'
#' @details
#' geoGraph's `gData` objects are matched to a base world graph by name, and
#' that graph must be loaded into the global environment for geoGraph's
#' internal methods to find it (this mirrors calling e.g.
#' `data(worldgraph.10k)` yourself before using geoGraph directly). If
#' `graph` is not already present in the global environment, this function
#' loads it there as a side effect.
#'
#' @param soc_id Character vector of two or more D-PLACE society IDs (see
#'   [dp_societies()]). Societies with missing coordinates are dropped with
#'   a warning; unknown IDs are dropped with a warning.
#' @param graph Name of the bundled geoGraph world graph to route paths
#'   through. Defaults to `"worldgraph.10k"` (10,242 nodes, sea-crossing
#'   edges removed); `"worldgraph.40k"` is available in geoGraph for higher
#'   resolution at the cost of speed.
#'
#' @return A tibble with one row per unique pair of the input societies:
#'   `soc_id_1`, `soc_id_2`, and `distance_km`, the least-cost land-route
#'   distance in kilometres. If two societies snap to the same underlying
#'   graph node (possible at coarser resolutions when societies are close
#'   together), their distance is `0` and a warning is issued; consider
#'   `graph = "worldgraph.40k"` for finer resolution in that case.
#'
#' @examples
#' \dontrun{
#' get_pairwise_geo_distance(c("B72", "B73", "B79"))
#' }
#'
#' @export
get_pairwise_geo_distance <- function(soc_id, graph = "worldgraph.10k") {
  if (length(soc_id) < 2) {
    stop("`soc_id` must contain at least two society IDs.", call. = FALSE)
  }
  if (anyDuplicated(soc_id)) {
    stop("`soc_id` contains duplicate values.", call. = FALSE)
  }

  if (!requireNamespace("geoGraph", quietly = TRUE)) {
    stop(
      "get_pairwise_geo_distance() requires the 'geoGraph' package, which ",
      "is not on CRAN. Install it with:\n",
      "  if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\")\n",
      "  BiocManager::install(c(\"graph\", \"RBGL\"))\n",
      "  install.packages(\"pak\")\n",
      "  pak::pak(\"EvolEcolGroup/geograph\")",
      call. = FALSE
    )
  }

  soc <- dp_societies(soc_id = soc_id, type = NULL)

  missing_ids <- setdiff(soc_id, soc$soc_id)
  if (length(missing_ids) > 0) {
    warning(
      "Society ID(s) not found, dropped: ", paste(missing_ids, collapse = ", "),
      call. = FALSE
    )
  }

  no_coords <- is.na(soc$latitude) | is.na(soc$longitude)
  if (any(no_coords)) {
    warning(
      "Dropping society(ies) with missing coordinates: ",
      paste(soc$soc_id[no_coords], collapse = ", "),
      call. = FALSE
    )
    soc <- soc[!no_coords, , drop = FALSE]
  }

  if (nrow(soc) < 2) {
    stop("Fewer than two societies with valid coordinates were found.", call. = FALSE)
  }

  if (!exists(graph, envir = globalenv())) {
    utils::data(list = graph, package = "geoGraph", envir = globalenv())
  }

  coords <- as.matrix(soc[, c("longitude", "latitude")])
  rownames(coords) <- soc$soc_id

  g_data <- methods::new("gData", coords = coords, gGraph.name = graph)

  # getNodes() gives the node each row of `g_data` (in the same order we
  # supplied `coords`) was snapped to.
  node_ids <- geoGraph::getNodes(g_data)
  if (is.null(node_ids) || length(node_ids) != nrow(soc)) {
    stop(
      "Could not match geoGraph's output back to society IDs -- this may ",
      "indicate an incompatible geoGraph version. Please report this issue.",
      call. = FALSE
    )
  }

  pairs_idx <- utils::combn(seq_len(nrow(soc)), 2)

  same_node <- node_ids[pairs_idx[1, ]] == node_ids[pairs_idx[2, ]]
  if (any(same_node)) {
    warning(
      "Some societies snapped to the same graph node at this resolution: ",
      paste(
        paste(soc$soc_id[pairs_idx[1, same_node]], soc$soc_id[pairs_idx[2, same_node]], sep = "-"),
        collapse = ", "
      ),
      ". Consider graph = \"worldgraph.40k\" for finer resolution.",
      call. = FALSE
    )
  }

  # NB: despite gPath2dist()'s documentation describing a `dist` object,
  # calling it on dijkstraBetween(gData) actually returns a plain named
  # numeric vector, one value per pair of input rows in the same order as
  # combn(seq_len(n), 2), with each name formatted "<node1>:<node2>". We
  # verify that expectation explicitly rather than trust it blindly, since
  # geoGraph is not on CRAN and its behaviour isn't guaranteed stable.
  path <- geoGraph::dijkstraBetween(g_data)
  d <- geoGraph::gPath2dist(path)

  expected_names <- paste0(node_ids[pairs_idx[1, ]], ":", node_ids[pairs_idx[2, ]])
  if (length(d) != ncol(pairs_idx) || !identical(unname(names(d)), expected_names)) {
    stop(
      "geoGraph's pairwise distance output did not have the expected ",
      "structure (this may indicate an incompatible geoGraph version). ",
      "Please report this issue.",
      call. = FALSE
    )
  }

  tibble::tibble(
    soc_id_1 = soc$soc_id[pairs_idx[1, ]],
    soc_id_2 = soc$soc_id[pairs_idx[2, ]],
    distance_km = as.numeric(d)
  )
}
