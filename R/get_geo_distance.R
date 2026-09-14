#' Geographic distance from a point or society to a list of societies
#'
#' Computes the land-route (least-cost) geographic distance, via the
#' 'geoGraph' package, from a single reference point -- either an existing
#' D-PLACE society or an arbitrary coordinate -- to each society in a list.
#' For distances between all pairs within a set of societies, use
#' [get_pairwise_geo_distance()] instead; this function shares that one's
#' method and dependency (see its documentation for install instructions and
#' methodological details).
#'
#' @param point Either a single D-PLACE society ID (character, see
#'   [dp_societies()]), or a named numeric vector of length 2,
#'   `c(longitude = ..., latitude = ...)`, giving an arbitrary coordinate.
#' @param soc_id Character vector of one or more D-PLACE society IDs to
#'   compute the distance to (see [dp_societies()]). Unknown IDs, and
#'   societies with missing coordinates, are dropped with a warning.
#' @param graph Name of the bundled geoGraph world graph to route paths
#'   through. Defaults to `"worldgraph.10k"`; `"worldgraph.40k"` is
#'   available in geoGraph for higher resolution at the cost of speed.
#'
#' @return A tibble with one row per society in `soc_id`: `soc_id` and
#'   `distance_km`, the least-cost land-route distance in kilometres from
#'   `point`. If `point` snaps to the same underlying graph node as a
#'   society (possible at coarser resolutions when they're close together),
#'   that distance is `0` and a warning is issued.
#'
#' @examples
#' \dontrun{
#' get_geo_distance("B72", c("B73", "B79"))
#' get_geo_distance(c(longitude = 20, latitude = -20), c("B72", "B73", "B79"))
#' }
#'
#' @export
get_geo_distance <- function(point, soc_id, graph = "worldgraph.10k") {
  if (length(soc_id) < 1) {
    stop("`soc_id` must contain at least one society ID.", call. = FALSE)
  }

  # Resolving `point` and `soc_id` doesn't need geoGraph, so validate those
  # first and only require the package once we actually need to route paths.
  point_coord <- .geo_dist_resolve_point(point)

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
      paste(soc$soc_id[no_coords], collapse = ", "), call. = FALSE
    )
    soc <- soc[!no_coords, , drop = FALSE]
  }
  if (nrow(soc) < 1) {
    stop("No societies with valid coordinates were found.", call. = FALSE)
  }

  if (!requireNamespace("geoGraph", quietly = TRUE)) {
    stop(
      "get_geo_distance() requires the 'geoGraph' package, which is not on ",
      "CRAN. See ?get_pairwise_geo_distance for install instructions.",
      call. = FALSE
    )
  }

  if (!exists(graph, envir = globalenv())) {
    utils::data(list = graph, package = "geoGraph", envir = globalenv())
  }

  coords <- rbind(point_coord, as.matrix(soc[, c("longitude", "latitude")]))
  rownames(coords) <- c("__point__", soc$soc_id)

  g_data <- methods::new("gData", coords = coords, gGraph.name = graph)

  # getNodes() gives the node each row of `g_data` (in the same order we
  # supplied `coords`, point first) was snapped to.
  node_ids <- geoGraph::getNodes(g_data)
  if (is.null(node_ids) || length(node_ids) != nrow(coords)) {
    stop(
      "Could not match geoGraph's output back to society IDs -- this may ",
      "indicate an incompatible geoGraph version. Please report this issue.",
      call. = FALSE
    )
  }

  n <- nrow(coords)
  pairs_idx <- utils::combn(n, 2)
  # `point` is row 1, so (by combn()'s lexicographic column order) the pairs
  # involving it are exactly the first n - 1 columns: (1,2), (1,3), ..., (1,n).
  point_pairs <- which(pairs_idx[1, ] == 1)
  if (!identical(point_pairs, seq_len(n - 1))) {
    stop(
      "Internal error matching point-to-society pairs. Please report this issue.",
      call. = FALSE
    )
  }

  same_node <- node_ids[1] == node_ids[-1]
  if (any(same_node)) {
    warning(
      "`point` snapped to the same graph node as: ",
      paste(soc$soc_id[same_node], collapse = ", "),
      ". Distance recorded as 0; consider graph = \"worldgraph.40k\" for finer resolution.",
      call. = FALSE
    )
  }

  # NB: see get_pairwise_geo_distance()'s source for why gPath2dist() is
  # treated as returning a plain named numeric vector rather than a `dist`
  # object, and why that's verified explicitly rather than trusted blindly.
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
    soc_id = soc$soc_id,
    distance_km = as.numeric(d)[point_pairs]
  )
}

# --- internal helper (not exported) -----------------------------------------

# Resolve `point` (a society ID or a named longitude/latitude vector) to a
# 1-row matrix with columns "longitude", "latitude".
.geo_dist_resolve_point <- function(point) {
  if (is.character(point) && length(point) == 1) {
    soc <- dp_societies(soc_id = point, type = NULL)
    if (nrow(soc) == 0) {
      stop("`point` society ID not found: ", point, call. = FALSE)
    }
    if (is.na(soc$latitude) || is.na(soc$longitude)) {
      stop("`point` society '", point, "' has no recorded coordinates.", call. = FALSE)
    }
    return(matrix(
      c(soc$longitude, soc$latitude), nrow = 1,
      dimnames = list(NULL, c("longitude", "latitude"))
    ))
  }

  if (is.numeric(point) && length(point) == 2 &&
      !is.null(names(point)) && setequal(names(point), c("longitude", "latitude"))) {
    point <- point[c("longitude", "latitude")]
    return(matrix(point, nrow = 1, dimnames = list(NULL, c("longitude", "latitude"))))
  }

  stop(
    "`point` must be either a single D-PLACE society ID (character), or a ",
    "named numeric vector c(longitude = ..., latitude = ...).",
    call. = FALSE
  )
}
