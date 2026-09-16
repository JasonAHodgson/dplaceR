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
* `dp_topics()` splits every variable's (often compound) `category` string
  into its individual topics and returns one row per variable/topic pair
  (`var_id`, `var_name`, `topic`), for browsing, counting, or filtering on a
  single clean topic -- e.g. `sort(table(dp_topics()$topic), decreasing = TRUE)`
  for topic counts, or `dp_topics(topic = "Subsistence")`. Topics are split
  and trimmed but not otherwise normalized: D-PLACE's own category text has
  a handful of near-duplicate topics (`"Labor"`/`"Labour"`,
  `"Settlement"`/`"Settlements"`, `"Dwelling"`/`"Dwellings"`,
  `"Wealth Transactions"`/`"Wealth transactions"`, `"War"`/`"Warfare"`), and
  both spellings appear as distinct topics rather than being silently
  merged -- `topic` supports `contains()` (case-insensitive by default) to
  combine them yourself, e.g. `topic = contains("Wealth")`.
* `dp_topic_list()` returns a sorted character vector of every distinct
  topic -- a quick `sort(unique(dp_topics()$topic))` to see what's
  available before filtering by it.
* `dp_topic_table()` returns a two-column tibble (`topic`, `n_variables`),
  one row per topic in the same order as `dp_topic_list()`, counting how
  many variables carry each -- a quick way to see which topics are broad
  and which are narrow before filtering by one.
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
* `dplace_societies` gains an `xd_id` column: D-PLACE's cross-dataset
  identifier, linking societies from different contributed datasets that
  independently code the same real-world group -- e.g. the !Kung are coded
  separately by Binford's dataset, the Ethnographic Atlas, and the Standard
  Cross-Cultural Sample, and all three share `xd_id = "xd1"`. This column
  was present in D-PLACE's own CLDF data all along but was previously
  dropped when building this package's bundled data. Most societies
  (roughly 70% of the bundled snapshot) have no `xd_id` at all (`NA`) --
  they haven't been cross-referenced to another dataset. `xd_id` is now
  also a filter argument on both `dp_societies()` and `get_society()`, with
  full `contains()` support, e.g. `get_society(xd_id = "xd1")`.
* `get_related_societies()` finds every other society sharing a given
  society's `xd_id` -- e.g. `get_related_societies("B72")` returns the !Kung
  codings from the Ethnographic Atlas and the SCCS alongside Binford's own.
  Accepts multiple society IDs at once (one row per queried/related pair in
  the result, so each input's matches stay traceable); warns (but doesn't
  error) for an unknown society ID, a society with no `xd_id`, or an
  `xd_id` that currently has no other society sharing it -- as long as at
  least one requested society has an `xd_id` at all.
* `dplace_societies` gains `lang_family_id`/`lang_family` columns: each
  society's top-level Glottolog language family (e.g.
  `lang_family_id = "indo1319"`, `lang_family = "Indo-European"`). Named
  `lang_family*` (not plain `family`) to avoid clashing with D-PLACE's own
  "family" cultural/kinship variables, which mean something unrelated.
  D-PLACE's own CLDF data has no family classification at all (only a leaf
  Glottocode per society), so this is joined in from a separate, pinned
  Glottolog CLDF release (see `dplace_meta`'s new
  `glottolog_version`/`glottolog_source_repo` columns, and `dp_citation()`,
  which now reports it too) -- every one of the 2837 distinct Glottocodes
  in the bundled D-PLACE snapshot matched. An isolate (a language with no
  known relatives, e.g. Zuni) is its own top-level family, so
  `lang_family`/`lang_family_id` equal the language's own name/Glottocode
  in that case; `NA` for the small number of societies with no `glottocode`
  at all. `lang_family`/`lang_family_id` are now filter arguments on both
  `dp_societies()` and `get_society()`, with full `contains()` support --
  e.g. `get_society(lang_family = "Indo-European")` or
  `dp_societies(lang_family = contains("Austro"))` to match both
  Austroasiatic and Austronesian at once.
* `dp_lang_family_list()` returns a sorted character vector of every
  distinct top-level language family among coded (`type = "society"`)
  societies -- a quick way to see what's available before filtering by
  `lang_family`.
* `dp_lang_family_table()` returns a two-column tibble (`lang_family`,
  `n_societies`), one row per family in the same order as
  `dp_lang_family_list()`, counting how many coded societies belong to each
  -- a quick way to see which families are well represented before
  filtering by one.
* Licence change: dplaceR is now licensed under GPL (>= 3) (was MIT), to
  match the 'tidypopgen' package.
* dplaceR now asks to be cited in its own right, alongside D-PLACE: an
  `inst/CITATION` file (so `citation("dplaceR")` returns a proper reference,
  crediting Jason A. Hodgson as package author), a `CITATION.cff` file at
  the repository root (for GitHub's native "Cite this repository" widget),
  and updated wording in `dp_citation()`, the package startup message, the
  package-level help page (`?dplaceR`), and the README all now ask users to
  cite the dplaceR package itself in addition to D-PLACE and the source
  dataset(s).
* `dp_search_variables()` gains a `type` argument (`"Categorical"`,
  `"Ordinal"`, and/or `"Continuous"`, passed straight to `dp_variables()`),
  so you can search by keyword and restrict to a variable type in one call
  instead of going through `dp_variables(search = ..., type = ...)`
  yourself.
* `dp_topics()`, `dp_topic_list()`, and `dp_topic_table()` gain a `type`
  argument, restricting topic browsing/counting to variables of the given
  type(s) -- applied before variables are split into topics, so it selects
  which variables (and hence which variable/topic pairs) contribute to the
  result. (`dp_variables()`, `get_society_data()`, `get_cult_distance()`,
  and `get_pairwise_cult_distance()` already supported filtering by `type`.)
* Bug fix: `get_cult_distance()` and `get_pairwise_cult_distance()` no
  longer treat D-PLACE's own "missing data" sentinel code (a dedicated
  code per variable, e.g. `"B017-NA"`, always with `ord = 99`) as a real
  observed state. Roughly a quarter of recorded categorical observations
  and 40% of recorded ordinal observations in the bundled snapshot use
  this sentinel rather than a genuine value, and because it's a real
  (non-`NA`) `code_id`, it previously flowed straight through as if it
  were one: two societies both explicitly coded "missing" on a variable
  would register as *matching* on it, and for ordinal variables its
  `ord = 99` would pollute `.cult_dist_var_range()`'s range and any
  `type_aware = TRUE` scaled comparison against it. Such observations are
  now dropped before comparison -- including in `modal = TRUE`'s modal-vote
  calculation, and when `culture` is a single society ID -- leaving the
  society/variable combination with no recorded state, exactly as if
  D-PLACE had never recorded anything for it. This does not affect
  `dp_variable_data()`/`get_society_data()`, which already surface the
  sentinel transparently via `code_label = "Missing data"` rather than
  silently treating it as data.
