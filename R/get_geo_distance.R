#' Geographic distance from a point or society to a list of societies
#'
#' Computes the geographic distance from a single reference point -- either
#' an existing D-PLACE society or an arbitrary coordinate -- to each society
#' in a list, using one of three distinct measures selected by `method`. For
#' distances between all pairs within a set of societies, use
#' [get_pairwise_geo_distance()] instead; it supports the same three
#' `method`s and shares this function's dependencies for the two that need
#' the 'geoGraph' package.
#'
#' The three `method`s are not different estimates of the same thing -- they
#' measure genuinely different quantities, and there is deliberately no
#' default, so every call has to say which one it means:
#'
#' \describe{
#'   \item{`"migration"`}{The number of steps across geoGraph's world grid
#'     along the least-cost land route (sea crossings excluded), using the
#'     habitat-based cost that ships with the bundled graph -- **not** a
#'     physical distance of any kind, in km or otherwise, despite returning a
#'     plausible-looking number. It's an index of how many grid cells a route
#'     has to cross, useful as a proxy for how easy or hard a migration route
#'     is (e.g. for isolation-by-distance-style analyses), but not
#'     interpretable in real-world units. Requires 'geoGraph'.}
#'   \item{`"great_circle"`}{The straight-line (haversine) distance in km
#'     between the two coordinates, ignoring land/sea entirely -- the
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
#' (which can be a meaningful fraction of the total for nearby points at
#' `worldgraph.10k`'s resolution; use `graph = "worldgraph.40k"` to shrink
#' it) specifically to guarantee this.
#'
#' @param point Either a single D-PLACE society ID (character, see
#'   [dp_societies()]), or a named numeric vector of length 2,
#'   `c(longitude = ..., latitude = ...)`, giving an arbitrary coordinate.
#' @param soc_id Character vector of one or more D-PLACE society IDs to
#'   compute the distance to (see [dp_societies()]). Unknown IDs, and
#'   societies with missing coordinates, are dropped with a warning.
#' @param method One of `"migration"`, `"great_circle"`, or
#'   `"land_route_km"` -- see Details. There is no default; it must be
#'   supplied explicitly.
#' @param graph Name of the bundled geoGraph world graph to route paths
#'   through. Only used by `method = "migration"` or `"land_route_km"`;
#'   ignored (and 'geoGraph' not required at all) for `"great_circle"`.
#'   Defaults to `"worldgraph.10k"`; `"worldgraph.40k"` is available in
#'   geoGraph for higher resolution at the cost of speed.
#'
#' @return A tibble with one row per society in `soc_id` that has a
#'   computable distance to `point`: `soc_id` and `distance` (units depend on
#'   `method` -- see Details; always km for `"great_circle"` and
#'   `"land_route_km"`, arbitrary graph-cost units for `"migration"`). For
#'   the two graph-based methods, if `point` snaps to the same underlying
#'   graph node as a society (possible at coarser resolutions when they're
#'   close together), a warning is issued; for `"migration"` that distance
#'   is exactly `0` (no routing needed between identical nodes), while for
#'   `"land_route_km"` it's the sum of both endpoints' snap distances (see
#'   Details) rather than `0`, since sharing a graph node doesn't mean
#'   `point` and the society have identical real-world coordinates. And
#'   since sea-crossing edges are removed from the graph, a society on a
#'   landmass with no land route to `point` (e.g. across an ocean, on
#'   another continent, or on an island) has no computable distance -- it's
#'   dropped from the result and reported in a warning, rather than failing
#'   the whole call. `"great_circle"` has neither restriction: every society
#'   with valid coordinates gets a row.
#'
#' @examples
#' \dontrun{
#' get_geo_distance("B72", c("B73", "B79"), method = "great_circle")
#' get_geo_distance("B72", c("B73", "B79"), method = "land_route_km")
#' get_geo_distance(
#'   c(longitude = 20, latitude = -20), c("B72", "B73", "B79"),
#'   method = "migration"
#' )
#' }
#'
#' @export
get_geo_distance <- function(point, soc_id, method, graph = "worldgraph.10k") {
  method <- .geo_dist_check_method(method)

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

  if (method == "great_circle") {
    # unname(): indexing a single row/column out of a matrix keeps the
    # column's dimname as the resulting scalar's name (e.g. "longitude"),
    # which would otherwise silently propagate through the arithmetic below
    # and onto the `distance` column itself.
    d <- .geo_dist_haversine_km(
      unname(point_coord[1, "longitude"]), unname(point_coord[1, "latitude"]),
      soc$longitude, soc$latitude
    )
    return(tibble::tibble(soc_id = soc$soc_id, distance = d))
  }

  # From here on, `method` is "migration" or "land_route_km" -- both route
  # across geoGraph's world grid.
  if (!requireNamespace("geoGraph", quietly = TRUE)) {
    stop(
      "get_geo_distance() with method = \"", method, "\" requires the ",
      "'geoGraph' package, which is not on CRAN. See ?get_pairwise_geo_distance ",
      "for install instructions -- or use method = \"great_circle\", which ",
      "doesn't need it.",
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

  # Snap `point` to its nearest graph node on its own (rather than folding it
  # into the societies' gData, as in an earlier version of this function) --
  # dijkstraFrom() below takes it as a separate `start` argument.
  rownames(point_coord) <- "__point__"
  point_g_data <- methods::new("gData", coords = point_coord, gGraph.name = graph)
  point_node <- geoGraph::getNodes(point_g_data)
  if (is.null(point_node) || length(point_node) != 1) {
    stop(
      "Could not match geoGraph's output back to `point` -- this may ",
      "indicate an incompatible geoGraph version. Please report this issue.",
      call. = FALSE
    )
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

  # `graph` has sea-crossing edges removed, so it's not fully connected --
  # drop any society with no land route to `point` (dijkstraFrom() would
  # otherwise error out for the whole call).
  comp_labels <- .geo_dist_component_labels(graph_obj)
  point_label <- comp_labels[point_node]
  soc_labels <- comp_labels[node_ids]
  unreachable <- is.na(soc_labels) | is.na(point_label) | soc_labels != point_label
  if (any(unreachable)) {
    warning(
      "`point` has no land route to: ", paste(soc$soc_id[unreachable], collapse = ", "),
      " (they're on a landmass this graph has no land connection to -- e.g. ",
      "across an ocean, on another continent, or on an island). Dropped ",
      "from the result.",
      call. = FALSE
    )
    soc <- soc[!unreachable, , drop = FALSE]
    coords <- coords[!unreachable, , drop = FALSE]
    node_ids <- node_ids[!unreachable]
    if (nrow(soc) < 1) {
      stop("`point` has no land route to any of the requested societies.", call. = FALSE)
    }
  }

  # A society that snaps to the same graph node as `point` has distance 0 by
  # definition, and is handled directly here rather than asked of
  # dijkstraFrom() below -- routing a node to itself isn't a case its
  # documentation describes, so we don't rely on undocumented behaviour for it.
  same_as_point <- node_ids == point_node
  if (any(same_as_point)) {
    warning(
      "`point` snapped to the same graph node as: ",
      paste(soc$soc_id[same_as_point], collapse = ", "),
      ". Distance recorded as 0; consider graph = \"worldgraph.40k\" for finer resolution.",
      call. = FALSE
    )
  }

  distance <- rep(NA_real_, nrow(soc))
  distance[same_as_point] <- 0

  if (any(!same_as_point)) {
    query_g_data <- methods::new(
      "gData", coords = coords[!same_as_point, , drop = FALSE], gGraph.name = graph
    )
    query_node_ids <- geoGraph::getNodes(query_g_data)

    # dijkstraFrom() computes a single shortest-path tree from `point_node`
    # out to every node in `query_g_data` -- one Dijkstra run -- rather than
    # dijkstraBetween()'s all-pairs computation, which would also (and
    # needlessly) compute every society-to-society distance. geoGraph's own
    # dijkstraFrom() reorders (and, if needed, duplicates) its result to
    # match query_g_data's node order -- see its source for the
    # `match(getNodes(x), ...)` step -- but since that behaviour isn't
    # documented and geoGraph's behaviour isn't guaranteed stable, we verify
    # the result lines up with `query_node_ids` explicitly rather than trust
    # it blindly.
    path <- geoGraph::dijkstraFrom(query_g_data, start = point_node)

    # NB: each element of `path` is named "<point_node>:<destination node>"
    # (the full origin:destination pair -- confirmed against geoGraph's
    # actual output, not just the destination, despite an internal gsub()
    # step inside dijkstraFrom() that might suggest otherwise; that gsub()
    # only strips the origin for a local variable used to reorder the
    # result, not for the names on the object it actually returns). We
    # verify against `path` itself (always reliably named) rather than
    # gPath2dist()'s output, since the latter's type -- a plain named vector
    # or a `dist` object with no names at all -- depends on the data (e.g.
    # whether the requested destinations happen to coincide), not on which
    # function produced it; see get_pairwise_geo_distance()'s source for the
    # same issue in the all-pairs case.
    expected_names <- paste0(point_node, ":", query_node_ids)
    if (length(path) != length(query_node_ids) ||
        !identical(unname(names(path)), expected_names)) {
      stop(
        "geoGraph's single-source distance output did not have the expected ",
        "structure (this may indicate an incompatible geoGraph version). ",
        "Please report this issue.",
        call. = FALSE
      )
    }
    d <- as.numeric(geoGraph::gPath2dist(path))
    if (length(d) != length(query_node_ids)) {
      stop(
        "geoGraph's single-source distance output did not have the expected ",
        "length after gPath2dist() (this may indicate an incompatible ",
        "geoGraph version). Please report this issue.",
        call. = FALSE
      )
    }
    distance[!same_as_point] <- d
  }

  if (method == "land_route_km") {
    # The routed distance above is between the GRAPH NODES `point` and each
    # society snap to, not their exact coordinates -- at worldgraph.10k's
    # resolution (10,242 nodes worldwide) that snap can shift each endpoint
    # by up to roughly one grid cell. Adding each endpoint's own snap
    # distance (its raw coordinate to the node it snapped to) turns the
    # total into a genuine upper bound on the real point-to-society
    # distance: routing via any sequence of intermediate points -- the two
    # snapped nodes included -- can never be shorter than the direct
    # great-circle distance between the original, un-snapped endpoints. That
    # guarantee (`land_route_km >= great_circle`, see Details) does NOT hold
    # for the routed distance alone: two nodes can end up closer together
    # than the raw coordinates that snapped to them were.
    node_coords <- geoGraph::getCoords(graph_obj) # rownames = node ids; cols lon, lat
    point_snap_km <- .geo_dist_haversine_km(
      unname(point_coord[1, "longitude"]), unname(point_coord[1, "latitude"]),
      unname(node_coords[point_node, 1]), unname(node_coords[point_node, 2])
    )
    soc_snap_km <- .geo_dist_haversine_km(
      unname(node_coords[node_ids, 1]), unname(node_coords[node_ids, 2]),
      unname(coords[, "longitude"]), unname(coords[, "latitude"])
    )
    distance <- distance + point_snap_km + soc_snap_km
  }

  tibble::tibble(
    soc_id = soc$soc_id,
    distance = distance
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
