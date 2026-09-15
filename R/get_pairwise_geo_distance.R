#' Pairwise geographic distance between societies
#'
#' Computes the pairwise geographic distance between D-PLACE societies, using
#' one of three distinct measures selected by `method`. See [get_geo_distance()]
#' for the same three measures applied to a single reference point vs. a list
#' of societies rather than all pairs within one list; the two functions
#' share their `method` semantics and, for the two methods that need it, the
#' 'geoGraph' dependency described below.
#'
#' The three `method`s measure genuinely different quantities, and there is
#' deliberately no default, so every call has to say which one it means:
#'
#' \describe{
#'   \item{`"migration"`}{The number of steps across geoGraph's world grid
#'     along the least-cost land route between each pair (sea crossings
#'     excluded), using the habitat-based cost that ships with the bundled
#'     graph -- **not** a physical distance of any kind, in km or otherwise,
#'     despite returning a plausible-looking number. It's an index of how
#'     many grid cells a route has to cross, useful as a proxy for how easy
#'     or hard a migration route is (e.g. for isolation-by-distance-style
#'     analyses), but not interpretable in real-world units. This was this
#'     function's only behaviour before `method` existed. Requires
#'     'geoGraph' (Andrea Manica's group,
#'     \url{https://github.com/EvolEcolGroup/geograph}; not on CRAN).}
#'   \item{`"great_circle"`}{The straight-line (haversine) distance in km
#'     between each pair's coordinates, ignoring land/sea entirely -- the
#'     shortest distance "as the crow flies". Needs neither 'geoGraph' nor
#'     `graph`, is always computable (no connectivity restrictions), and is
#'     fast even for very large `soc_id` lists.}
#'   \item{`"land_route_km"`}{The actual physical distance in km along the
#'     same least-cost land route as `"migration"`, but with each grid edge
#'     weighted by its true great-circle length rather than an arbitrary
#'     habitat-based cost. This is what `"migration"` might look like it's
#'     giving you, but doesn't -- if you want real km that respect land
#'     routing (rather than a straight line through oceans), this is the one
#'     to use. Requires 'geoGraph'.}
#' }
#'
#' `"land_route_km"` will always be greater than or equal to `"great_circle"`
#' for the same pair, since a land route can never be shorter than a
#' straight line between the same two points -- `"land_route_km"` includes
#' the distance from each raw coordinate to the graph node it snaps to
#' (which can be a meaningful fraction of the total for nearby societies at
#' `worldgraph.10k`'s resolution; use `graph = "worldgraph.40k"` to shrink
#' it) specifically to guarantee this.
#'
#' 'geoGraph' is not on CRAN and is a Suggested, not required, dependency of
#' dplaceR -- `method = "migration"` and `"land_route_km"` are only usable
#' once it (and its own dependencies) are installed; `"great_circle"` never
#' needs it. Install it with:
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
#' `data(worldgraph.10k)` yourself before using geoGraph directly). For
#' `method = "migration"`, if `graph` is not already present in the global
#' environment, this function loads it there as a side effect (and leaves it
#' there afterwards, as before). For `method = "land_route_km"`, a
#' km-weighted copy of `graph` is temporarily installed under that same name
#' so geoGraph's routing functions can find it, and whatever was there before
#' (or nothing, if it wasn't loaded yet) is restored once the call finishes --
#' so this method never leaves a modified graph behind in your global
#' environment.
#'
#' @param soc_id Character vector of two or more D-PLACE society IDs (see
#'   [dp_societies()]). Societies with missing coordinates are dropped with
#'   a warning; unknown IDs are dropped with a warning.
#' @param method One of `"migration"`, `"great_circle"`, or
#'   `"land_route_km"` -- see Details. There is no default; it must be
#'   supplied explicitly.
#' @param graph Name of the bundled geoGraph world graph to route paths
#'   through. Only used by `method = "migration"` or `"land_route_km"`;
#'   ignored (and 'geoGraph' not required at all) for `"great_circle"`.
#'   Defaults to `"worldgraph.10k"` (10,242 nodes, sea-crossing edges
#'   removed); `"worldgraph.40k"` is available in geoGraph for higher
#'   resolution at the cost of speed.
#'
#' @return A tibble with one row per unique pair of the input societies:
#'   `soc_id_1`, `soc_id_2`, and `geo_distance` (units depend on `method` -- see
#'   Details; always km for `"great_circle"` and `"land_route_km"`,
#'   arbitrary graph-cost units for `"migration"`). For the two graph-based
#'   methods, if two societies snap to the same underlying graph node
#'   (possible at coarser resolutions when they're close together), a
#'   warning is issued; for `"migration"` their distance is exactly `0` (no
#'   routing needed between identical nodes), while for `"land_route_km"`
#'   it's the sum of both societies' snap distances (see Details) rather
#'   than `0`, since sharing a graph node doesn't mean two societies have
#'   identical real-world coordinates. Consider `graph = "worldgraph.40k"`
#'   for finer resolution in that case. Since
#'   sea-crossing edges are removed from the graph, it isn't fully connected
#'   -- a pair of societies with no land route between them (e.g. on
#'   different continents, or either on an island) gets `geo_distance = NA`,
#'   with a warning summarizing how many such pairs were found, rather than
#'   failing the whole call. `"great_circle"` has neither restriction: every
#'   pair of societies with valid coordinates gets a row.
#'
#' @examples
#' \dontrun{
#' get_pairwise_geo_distance(c("B72", "B73", "B79"), method = "great_circle")
#' get_pairwise_geo_distance(c("B72", "B73", "B79"), method = "land_route_km")
#' get_pairwise_geo_distance(c("B72", "B73", "B79"), method = "migration")
#' }
#'
#' @export
get_pairwise_geo_distance <- function(soc_id, method, graph = "worldgraph.10k") {
  method <- .geo_dist_check_method(method)

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

  pairs_idx <- utils::combn(seq_len(nrow(soc)), 2)

  if (method == "great_circle") {
    d <- .geo_dist_haversine_km(
      soc$longitude[pairs_idx[1, ]], soc$latitude[pairs_idx[1, ]],
      soc$longitude[pairs_idx[2, ]], soc$latitude[pairs_idx[2, ]]
    )
    return(tibble::tibble(
      soc_id_1 = soc$soc_id[pairs_idx[1, ]],
      soc_id_2 = soc$soc_id[pairs_idx[2, ]],
      geo_distance = d
    ))
  }

  # From here on, `method` is "migration" or "land_route_km" -- both route
  # across geoGraph's world grid.
  if (!requireNamespace("geoGraph", quietly = TRUE)) {
    stop(
      "get_pairwise_geo_distance() with method = \"", method, "\" requires ",
      "the 'geoGraph' package, which is not on CRAN -- or use ",
      "method = \"great_circle\", which doesn't need it. To install ",
      "'geoGraph':\n",
      "  if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\")\n",
      "  BiocManager::install(c(\"graph\", \"RBGL\"))\n",
      "  install.packages(\"pak\")\n",
      "  pak::pak(\"EvolEcolGroup/geograph\")",
      call. = FALSE
    )
  }

  if (method == "land_route_km") {
    restore_graph <- .geo_dist_install_km_graph(graph)
    on.exit(restore_graph(), add = TRUE)
  } else if (!exists(graph, envir = globalenv())) {
    utils::data(list = graph, package = "geoGraph", envir = globalenv())
  }
  graph_obj <- get(graph, envir = globalenv())

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

  # `graph` has sea-crossing edges removed, so it's not fully connected --
  # dijkstraBetween() errors out ("Not all nodes are connected by the
  # graph.") if asked to route between two nodes in different components.
  # Rather than fail the whole call over one unreachable pair, we group the
  # requested societies by connected component and run dijkstraBetween once
  # per group (of size >= 2); pairs spanning two different groups have no
  # land route and get `distance = NA`. This grouping only depends on which
  # edges exist, not their weight, so it's identical for "migration" and
  # "land_route_km".
  comp_labels <- .geo_dist_component_labels(graph_obj)
  soc_labels <- comp_labels[node_ids]
  # Defensive: every graph node should appear in some component, but if one
  # somehow doesn't, treat it as its own singleton group rather than letting
  # an NA propagate into the reachable/unreachable comparisons below.
  unresolved <- is.na(soc_labels)
  if (any(unresolved)) {
    soc_labels[unresolved] <- max(soc_labels, 0L, na.rm = TRUE) + seq_len(sum(unresolved))
  }
  reachable <- soc_labels[pairs_idx[1, ]] == soc_labels[pairs_idx[2, ]]

  d <- rep(NA_real_, ncol(pairs_idx))
  pair_key <- paste(pairs_idx[1, ], pairs_idx[2, ])

  groups <- split(seq_len(nrow(soc)), soc_labels)
  for (grp_idx in groups) {
    if (length(grp_idx) < 2) next # isolated society -- nothing to compute

    sub_g_data <- methods::new(
      "gData", coords = coords[grp_idx, , drop = FALSE], gGraph.name = graph
    )
    sub_node_ids <- geoGraph::getNodes(sub_g_data)
    if (is.null(sub_node_ids) || length(sub_node_ids) != length(grp_idx)) {
      stop(
        "Could not match geoGraph's output back to society IDs -- this may ",
        "indicate an incompatible geoGraph version. Please report this issue.",
        call. = FALSE
      )
    }
    sub_pairs_idx <- utils::combn(seq_along(grp_idx), 2)

    sub_path <- geoGraph::dijkstraBetween(sub_g_data)

    # NB: gPath2dist() returns a `dist` object (no names at all) when the
    # requested pairs span more than one distinct origin node -- the normal
    # case for 3+ societies -- and a plain named numeric vector when they
    # happen to share a single origin (always true for a 2-society group,
    # and also possible by coincidence for a larger one, e.g. if several
    # societies snap to the same graph node). Which one comes back is a
    # property of the *data*, not of the fact that this is dijkstraBetween()
    # rather than dijkstraFrom() -- so rather than assume a shape for
    # gPath2dist()'s own output, we verify structure against `sub_path`
    # itself (a plain list, always reliably named "<node1>:<node2>" in
    # combn() column order) and then rely on gPath2dist()/sapply()
    # preserving that same order regardless of which return type it picks --
    # true of both a `dist` object's canonical lower-triangle order and a
    # plain vector's list order, which happen to coincide with combn()'s own
    # pair order. We verify this explicitly rather than trust it blindly,
    # since geoGraph is not on CRAN and its behaviour isn't guaranteed
    # stable.
    expected_names <- paste0(
      sub_node_ids[sub_pairs_idx[1, ]], ":", sub_node_ids[sub_pairs_idx[2, ]]
    )
    if (length(sub_path) != ncol(sub_pairs_idx) ||
        !identical(unname(names(sub_path)), expected_names)) {
      stop(
        "geoGraph's pairwise distance output did not have the expected ",
        "structure (this may indicate an incompatible geoGraph version). ",
        "Please report this issue.",
        call. = FALSE
      )
    }
    sub_d <- as.numeric(geoGraph::gPath2dist(sub_path))
    if (length(sub_d) != ncol(sub_pairs_idx)) {
      stop(
        "geoGraph's pairwise distance output did not have the expected ",
        "length after gPath2dist() (this may indicate an incompatible ",
        "geoGraph version). Please report this issue.",
        call. = FALSE
      )
    }

    # Map this group's pair distances back into the full result vector.
    # split() preserves ascending order within `grp_idx`, and combn() always
    # emits pairs in lexicographic index order, so a simple key match (rather
    # than an O(n^2) search) is enough to place each value correctly.
    global_i <- grp_idx[sub_pairs_idx[1, ]]
    global_j <- grp_idx[sub_pairs_idx[2, ]]
    pos <- match(paste(global_i, global_j), pair_key)
    d[pos] <- sub_d
  }

  n_unreachable <- sum(!reachable)
  if (n_unreachable > 0) {
    warning(
      n_unreachable, " pair(s) of societies have no land route between them ",
      "by this graph (they fall into ", length(groups), " landmass group(s) ",
      "with no land connection to each other -- e.g. different continents ",
      "or islands) and are recorded as `geo_distance = NA`.",
      call. = FALSE
    )
  }

  if (method == "land_route_km") {
    # The routed distance above is between the GRAPH NODES each society
    # snaps to, not their exact coordinates -- at worldgraph.10k's
    # resolution (10,242 nodes worldwide) that snap can shift each endpoint
    # by up to roughly one grid cell. Adding each society's own snap
    # distance (its raw coordinate to the node it snapped to) turns the
    # total into a genuine upper bound on the real distance between the two
    # societies: routing via any sequence of intermediate points -- the two
    # snapped nodes included -- can never be shorter than the direct
    # great-circle distance between the original, un-snapped coordinates.
    # That guarantee (`land_route_km >= great_circle`, see Details) does NOT
    # hold for the routed distance alone: two nodes (even the SAME node, for
    # a `same_node` pair, whose routed distance is exactly 0) can end up
    # closer together than the raw coordinates that snapped to them were.
    node_coords <- geoGraph::getCoords(graph_obj) # rownames = node ids; cols lon, lat
    snap_km <- .geo_dist_haversine_km(
      unname(node_coords[node_ids, 1]), unname(node_coords[node_ids, 2]),
      unname(coords[, "longitude"]), unname(coords[, "latitude"])
    )
    # NA stays NA for unreachable pairs -- only reachable pairs' `d` changes.
    d <- d + snap_km[pairs_idx[1, ]] + snap_km[pairs_idx[2, ]]
  }

  tibble::tibble(
    soc_id_1 = soc$soc_id[pairs_idx[1, ]],
    soc_id_2 = soc$soc_id[pairs_idx[2, ]],
    geo_distance = d
  )
}
