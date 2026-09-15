# Shared internal helpers for get_geo_distance() and get_pairwise_geo_distance()
# -----------------------------------------------------------------------------
# geoGraph's bundled world graphs have sea-crossing edges removed, so they are
# not fully connected: landmasses with no land route between them (e.g.
# Australia, Madagascar, or the Americas vs. Afro-Eurasia, or any small
# island) form separate connected components. geoGraph's own
# dijkstraBetween() errors out ("Not all nodes are connected by the graph.")
# if asked to route between two nodes in different components. Both
# get_geo_distance() and get_pairwise_geo_distance() use the helper below to
# detect this ahead of time and drop/report the unreachable society(ies) or
# pair(s) instead of failing the whole call. This applies to their
# `method = "migration"` and `method = "land_route_km"` (both of which route
# across the graph); `method = "great_circle"` never touches the graph at
# all, so it has no such restriction.
#
# Not exported.

# Returns a named integer vector: for every node in `graph_obj`'s underlying
# graph, which connected component it belongs to (labels are arbitrary and
# only meaningful for equality comparison -- two nodes have a land route
# between them, per this graph, iff they share a label). `graph_obj` is the
# actual gGraph object (e.g. the loaded `worldgraph.10k`), not its name.
.geo_dist_component_labels <- function(graph_obj) {
  if (!requireNamespace("RBGL", quietly = TRUE)) {
    stop(
      "This requires the 'RBGL' package (a dependency of 'geoGraph' itself, ",
      "so it should already be installed alongside it -- see ",
      "?get_pairwise_geo_distance). If it's missing, install it with:\n",
      "  if (!requireNamespace(\"BiocManager\", quietly = TRUE)) install.packages(\"BiocManager\")\n",
      "  BiocManager::install(\"RBGL\")",
      call. = FALSE
    )
  }
  comps <- RBGL::connectedComp(geoGraph::getGraph(graph_obj))
  labels <- rep(seq_along(comps), lengths(comps))
  names(labels) <- unlist(comps, use.names = FALSE)
  labels
}

# `method` has no default in either exported function -- callers must state
# explicitly which of the three distance measures they want. This is
# deliberate: silently defaulting to one -- especially "migration", which
# returns small, plausible-looking numbers that are NOT a physical distance
# of any kind -- is exactly the mistake this three-way split exists to
# prevent. `missing(method)` here relies on R's usual rule that passing a
# bare (possibly-missing) argument symbol through to another function
# preserves its missingness, so this must always be called as
# `.geo_dist_check_method(method)`, not with any wrapping expression.
.geo_dist_check_method <- function(method) {
  if (missing(method) || length(method) == 0) {
    stop(
      "`method` must be supplied: one of \"migration\", \"great_circle\", or ",
      "\"land_route_km\" -- there is no default. See ?get_geo_distance or ",
      "?get_pairwise_geo_distance for what each one means.",
      call. = FALSE
    )
  }
  match.arg(method, c("migration", "great_circle", "land_route_km"))
}

# Great-circle (haversine) distance in km between two points given as
# longitude/latitude in decimal degrees, using the IUGG mean Earth radius.
# All four arguments are recycled against each other in the usual R way, so
# this works equally for a single pair or for vectors of coordinates (e.g.
# all `combn()` pairs at once). This is deliberately a plain, dependency-free
# implementation rather than a call to e.g. fields::rdist.earth() -- geoGraph
# already depends on 'fields', but rdist.earth() defaults to *miles*, not km
# (`miles = TRUE`), which is exactly the kind of silent-unit mismatch this
# whole `method` split exists to avoid; better to own the formula outright
# than to rely on remembering to override someone else's default.
.geo_dist_haversine_km <- function(lon1, lat1, lon2, lat2) {
  earth_radius_km <- 6371.0088 # IUGG mean radius
  to_rad <- pi / 180
  lat1 <- lat1 * to_rad
  lat2 <- lat2 * to_rad
  dlat <- lat2 - lat1
  dlon <- (lon2 - lon1) * to_rad
  a <- sin(dlat / 2)^2 + cos(lat1) * cos(lat2) * sin(dlon / 2)^2
  earth_radius_km * 2 * atan2(sqrt(a), sqrt(1 - a))
}

# Returns a copy of `graph_obj` (a gGraph object) with every edge's cost
# replaced by its actual great-circle distance in km (via
# .geo_dist_haversine_km()), instead of whatever habitat-based cost the
# bundled object ships with. Edges themselves (which pairs of nodes are
# connected) are untouched -- only their weight -- so connected-component
# membership, and therefore reachability, is identical to the unweighted
# graph; only the least-cost path lengths change.
.geo_dist_km_costs <- function(graph_obj) {
  E <- geoGraph::getEdges(graph_obj, res.type = "matNames")
  coords <- geoGraph::getCoords(graph_obj) # cols are lon, lat, in that order
  w <- .geo_dist_haversine_km(
    coords[E[, 1], 1], coords[E[, 1], 2],
    coords[E[, 2], 1], coords[E[, 2], 2]
  )
  graph::edgeData(graph_obj@graph, from = E[, 1], to = E[, 2], attr = "weight") <- w
  graph_obj
}

# geoGraph's dijkstraFrom()/dijkstraBetween() don't take a graph object as an
# argument -- a gData's `@gGraph.name` is just a string, and internally they
# look up the actual gGraph object *by that name in the global environment*
# (`get(x@gGraph.name, envir = .GlobalEnv)`) every time they're called. So to
# route with km-based costs instead of the bundled habitat-based ones, we
# have to temporarily replace that global binding -- and then restore
# whatever was there before (or remove it, if there was nothing), however
# the call ends, so a `method = "land_route_km"` call never leaves a
# modified graph sitting in the user's global environment afterwards.
#
# Always rebuilds from a pristine copy of the bundled data, regardless of
# what (if anything) is already bound to `graph_name` -- so repeated calls,
# or an already-modified graph of the same name, never compound.
#
# Returns a zero-argument function; callers must pass it straight to
# `on.exit(..., add = TRUE)` so the restore always happens, error or not.
.geo_dist_install_km_graph <- function(graph_name) {
  had_binding <- exists(graph_name, envir = globalenv(), inherits = FALSE)
  prior_value <- if (had_binding) get(graph_name, envir = globalenv(), inherits = FALSE) else NULL

  utils::data(list = graph_name, package = "geoGraph", envir = globalenv())
  pristine <- get(graph_name, envir = globalenv(), inherits = FALSE)
  assign(graph_name, .geo_dist_km_costs(pristine), envir = globalenv())

  function() {
    if (had_binding) {
      assign(graph_name, prior_value, envir = globalenv())
    } else if (exists(graph_name, envir = globalenv(), inherits = FALSE)) {
      rm(list = graph_name, envir = globalenv())
    }
  }
}
