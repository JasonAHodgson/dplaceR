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
