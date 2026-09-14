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
