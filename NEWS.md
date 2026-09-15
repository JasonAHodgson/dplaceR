# dplaceR 0.1.0

* Initial release.
* Bundles a snapshot of the D-PLACE CLDF dataset (v3.3.0).
* Functions to browse societies (`dp_societies()`), variables
  (`dp_variables()`, `dp_search_variables()`), codes (`dp_codes()`),
  values (`dp_values()`, `dp_variable_data()`), dataset contributions
  (`dp_contributions()`), and language phylogenies (`dp_trees()`,
  `dp_tree()`).
* `dp_citation()` prints citation and licence information for the bundled
  data.
* `get_pairwise_geo_distance()` computes pairwise least-cost, land-route
  geographic distances between societies using the 'geoGraph' package
  (Andrea Manica's group; not on CRAN, installed separately -- see the
  function's documentation).
* `get_pairwise_cult_distance()` computes pairwise cultural (dis)similarity
  between societies from one or more coded D-PLACE variables, with
  configurable handling of missing data (`missing`), the returned metric
  (`metric`), and optional type-aware scoring of ordinal/continuous
  variables (`type_aware`).
* `get_geo_distance()` computes the geographic (land-route) distance from a
  single point -- a D-PLACE society or an arbitrary coordinate -- to a list
  of societies, using the same method as `get_pairwise_geo_distance()`.
* `get_cult_distance()` computes cultural distance from a single reference
  culture -- a D-PLACE society, a custom profile, or a computed modal
  (most common) profile across a group of societies -- to a list of
  societies, using the same method as `get_pairwise_cult_distance()`.
* `get_society_meta()` appends society metadata (name, region, coordinates,
  etc.) to a tibble by society ID, auto-detecting `soc_id`/`soc_id_1`/
  `soc_id_2` columns as produced by this package's other functions.
* `dp_map_societies()` plots societies on a world map (via 'ggplot2' and
  'maps'), optionally coloured by another column and labelled by society ID.
* `get_society_country()` reverse-geocodes a society's coordinates to a
  country name (via 'maps'), since D-PLACE itself only records a broad,
  multi-country world region -- not country.
* `get_society()` searches for societies matching metadata criteria:
  exact-match filters on `soc_id`, `glottocode`, `iso_code`, `region`,
  `type`, `contribution_id`, and `language_level_glottocodes`; a
  case-insensitive partial match on `name`; single-value-or-range matching
  on `latitude`, `longitude`, and `main_focal_year`; and a `country` filter
  (via `get_society_country()` and the 'maps' package) applied last, after
  every other criterion has narrowed the search. All supplied criteria
  combine with AND.
* `contains()` switches an exact-match argument of `get_society()`/
  `dp_societies()` (`soc_id`, `glottocode`, `iso_code`, `region`,
  `contribution_id`, `language_level_glottocodes`) to a partial/regex match
  via `grepl()` instead -- e.g. `get_society(region = contains("Africa"))`,
  since D-PLACE splits Africa into several regions ("Southern Africa",
  "West Tropical Africa", etc.) with no single region literally called
  `"Africa"`. Supports multiple patterns (matched as OR), `ignore.case`
  (default `TRUE`), and `fixed` (literal instead of regex). Not supported
  for `type`, `name` (already a partial match), `country` (already
  case-insensitive), or the numeric arguments.
* `get_pairwise_language_distance()` and `get_language_distance()` compute
  linguistic (branch-length/"patristic") distance between societies' languages
  on a bundled D-PLACE language tree (`dp_trees()`/`dp_tree()`), mirroring
  `get_pairwise_geo_distance()`/`get_geo_distance()`'s pairwise/single-point
  split. Societies are matched to tree tips via `glottocode`, falling back to
  `language_level_glottocodes` when it names a single Glottocode;
  `get_language_distance()`'s `point` can be a D-PLACE society ID or a bare
  Glottocode. Two important caveats: branch length units are NOT consistent
  across D-PLACE's 114 bundled trees -- most are Glottolog's own family
  classification trees with small arbitrary integer branch lengths
  (classification depth, not time), while a minority are real dated
  phylogenies with branch lengths plausibly in years (check `dp_trees()`'s
  `source` column, and see the functions' documentation for details) -- so
  distances from different trees should not be treated as comparable; and a
  pair/society whose language is on a different tree entirely has no distance
  at all. A required `cross_tree` argument (no default) controls that second
  case: `"na"` records `NA` with a summarizing warning; a planned
  `"join_root"` option (graft the two trees at the root, using a `multiplier`
  of the larger tree's own root-to-tip depth as the cross-tree distance) is
  **not implemented yet** -- no established method for this was found (a
  literature/web search turned up nothing beyond supertree methods, which
  require overlapping taxa and don't apply here), and it needs more thought
  given the units caveat above, so `cross_tree = "join_root"` currently
  errors explaining this; `multiplier` (default `2`) is reserved in the
  signature for when it ships.
* `get_society_data()` searches and assembles D-PLACE's coded cultural data
  for a chosen set of societies and a chosen set of variables -- named
  explicitly (`var_id`), or found by searching (`category`, `type`,
  `search`, passed straight to `dp_variables()` and combined with AND; at
  least one of the four must be supplied). `format = "long"` (default)
  returns one row per society/variable observation, like
  `dp_variable_data()`, with variable metadata (`var_name`, `var_category`,
  `var_type`) added; `format = "wide"` returns one row per society and one
  column per variable (named by `var_id`), ready to use directly for
  analysis -- `"Continuous"` columns are numeric, `"Categorical"`/
  `"Ordinal"` columns hold the human-readable code label, and a society
  with more than one recorded observation for a variable has them collapsed
  to the most recent (by year), with a warning.
* `dp_variables()`'s `category` argument now supports `contains()` for a
  partial/regex match, for the same reason `region` needed it: many
  `category` values are several topics joined with `", "` (e.g.
  `"Economy, Property, Subsistence"`), so an exact match like
  `category = "Subsistence"` silently misses those --
  `category = contains("Subsistence")` matches any category string that
  mentions the term. Not supported for `type` (a fixed vocabulary).
* `get_cult_distance()` and `get_pairwise_cult_distance()` gained the same
  variable-selection criteria as `get_society_data()`: `var_id` is now
  optional, and `category`, `type`, and/or `search` can be given instead
  (or alongside it) to select the variable set by searching -- e.g.
  `get_pairwise_cult_distance(soc_id, category = contains("Subsistence"))`
  -- combined with AND and passed straight to `dp_variables()`, exactly as
  in `get_society_data()`. At least one of `var_id`/`category`/`type`/
  `search` must be supplied. Incidental fix: `get_pairwise_cult_distance()`'s
  "only one variable requested" warning is now based on the *resolved*
  variable set rather than the raw `var_id` argument, so it also fires when
  other variable(s) were requested but dropped as unmatched, leaving only
  one.
* Bug fix: `get_geo_distance()` and `get_pairwise_geo_distance()` no longer
  fail their whole call ("Not all nodes are connected by the graph.") when
  some requested societies have no land route to each other (e.g. they're on
  different continents, or either is on an island) -- 'geoGraph''s bundled
  world graphs have sea-crossing edges removed, so they aren't fully
  connected. Unreachable societies/pairs are now dropped/recorded as `NA`
  instead, with a warning, and only societies/pairs with a computable
  land-route distance are returned. This uses the 'RBGL' package (already a
  dependency of 'geoGraph' itself), now listed in Suggests.
* Performance: `get_geo_distance()` now uses geoGraph's single-source
  `dijkstraFrom()` (one shortest-path tree from `point`) instead of
  `dijkstraBetween()`'s all-pairs computation, which was also computing (and
  discarding) every society-to-society distance. This makes it efficient for
  large `soc_id` lists -- previously its cost grew roughly quadratically
  with the number of societies requested, the same as
  `get_pairwise_geo_distance()`'s inherently all-pairs cost, even though
  `get_geo_distance()` only ever needed point-to-society distances.
* Bug fix: `get_geo_distance()` and `get_pairwise_geo_distance()` no longer
  error with "geoGraph's ... distance output did not have the expected
  structure" on ordinary real-world input. Two distinct issues, both only
  reproducible against a live 'geoGraph' install (not in a sandbox without
  it): `dijkstraFrom()`'s result is named `"<origin>:<destination>"`, not
  just the destination, which `get_geo_distance()` didn't account for; and
  `gPath2dist()` returns a `dist` object with no `names()` at all -- rather
  than a named vector -- whenever the requested pairs span more than one
  distinct origin node (the normal case for 3+ societies), which
  `get_pairwise_geo_distance()` didn't account for either (this second issue
  predates the `dijkstraFrom()` work above and had been latent since the
  function was first written). Both functions now verify structure against
  the underlying `gPath` object, which is reliably named either way.
* Breaking change: `get_geo_distance()` and `get_pairwise_geo_distance()`
  gained a required `method` argument (no default) with three genuinely
  different measures: `"migration"` (their previous, only behaviour -- a
  least-cost path across geoGraph's world grid using its bundled
  habitat-based edge costs, which turns out to be an arbitrary graph-cost
  measure, *not* a physical distance despite past documentation implying
  otherwise -- see below); `"great_circle"` (straight-line haversine
  distance in km, ignoring land/sea entirely -- needs neither 'geoGraph' nor
  `graph`, and has no connectivity restrictions); and `"land_route_km"`
  (real physical distance in km along the same land-only route as
  `"migration"`, weighting each grid edge by its true great-circle length
  instead of an arbitrary cost, and adding each endpoint's own distance to
  the graph node it snapped to -- without that addition, routing between
  two *snapped* nodes could come out shorter than the straight line between
  the original, un-snapped coordinates, breaking the guarantee that
  `"land_route_km"` is always >= `"great_circle"` for the same pair). The
  output column is now called `geo_distance`
  (was `distance_km`) for both functions, since its units depend on
  `method` -- named specifically (rather than the generic `distance`) so it
  can't be confused with `get_cult_distance()`/`get_pairwise_cult_distance()`'s
  own `cult_distance` column when both are joined into the same tibble (e.g.
  via [get_society_meta()]) or plotted together. Existing code must be
  updated to pass `method` explicitly and to read `geo_distance` instead of
  `distance_km`.
* Bug fix: the values previously returned by `get_geo_distance()` and
  `get_pairwise_geo_distance()` (now `method = "migration"`) were
  mislabelled as kilometres (`distance_km`) but were never physical
  distances at all -- geoGraph's bundled `worldgraph.10k`/`worldgraph.40k`
  objects ship with a habitat-based edge cost (land-land edges cost ~1) with
  sea-crossing edges already removed, so the least-cost "distance" computed
  from them is effectively a hop count across the graph's grid, in arbitrary
  units -- confirmed against geoGraph's own source and its vignette (which
  labels this exact quantity "arbitrary units"). Real physical distance is
  now available via the new `method = "great_circle"` or `"land_route_km"`
  (see above); the latter deliberately doesn't use geoGraph's own
  `setDistCosts()`, since it computes distance via `fields::rdist.earth()`
  without overriding that function's default of *miles*, not km -- another
  silent-unit trap this package now avoids entirely by computing great-circle
  distance itself.
