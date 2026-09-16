# Plot a distance tree from a pairwise distance table

Builds and plots a distance-based tree (neighbor-joining or UPGMA) from
any of this package's pairwise distance/differentiation tables –
\[get_pairwise_geo_distance()\], \[get_pairwise_cult_distance()\],
\[get_pairwise_language_distance()\] (all keyed by
\`soc_id_1\`/\`soc_id_2\`), or \[get_pairwise_cultural_FST()\]'s
\`overall\`/\`by_variable\` tibbles (keyed by \`group_1\`/\`group_2\`) –
or any data frame following the same convention.

## Usage

``` r
plot_distance_tree(
  pairwise,
  distance_col = NULL,
  id_cols = NULL,
  method = c("nj", "upgma"),
  root = c("none", "midpoint", "outgroup"),
  outgroup = NULL,
  on_missing = c("drop", "error"),
  tip_label = c("id", "name"),
  ...
)
```

## Arguments

- pairwise:

  A data frame/tibble with one row per unique pair: two node-ID columns
  (auto-detected as \`soc_id_1\`/\`soc_id_2\` or
  \`group_1\`/\`group_2\`; see \`id_cols\`) and a numeric distance
  column (see \`distance_col\`).

- distance_col:

  Optional; the name of the numeric column in \`pairwise\` to use as the
  distance. If \`NULL\` (the default), used only when exactly one non-ID
  numeric column is present – otherwise, name it explicitly (e.g.
  \`"value"\` for \[get_pairwise_cultural_FST()\]'s tables, which also
  carry \`n_variables\`/\`n_groups\`).

- id_cols:

  Optional length-2 character vector naming the two node-ID columns, for
  a \`pairwise\` table that doesn't follow the \`soc_id_1\`/\`soc_id_2\`
  or \`group_1\`/\`group_2\` convention. If \`NULL\` (the default),
  auto-detected.

- method:

  Tree-building method: \`"nj"\` (neighbor-joining, via \[ape::nj()\] –
  the default, and the usual choice for a distance matrix that isn't
  guaranteed ultrametric) or \`"upgma"\` (average-linkage clustering,
  via \`stats::hclust(method = "average")\` – assumes a roughly
  clock-like/ultrametric distance and produces an already-rooted tree).

- root:

  Rooting applied to the resulting tree: \`"none"\` (the default – left
  exactly as \`method\` produces it: genuinely unrooted for \`"nj"\`, or
  rooted at its last merge for \`"upgma"\`), \`"midpoint"\` (root at the
  midpoint of the tree's longest tip-to-tip path, via
  \[phangorn::midpoint()\] – a reasonable default when no natural
  outgroup is available, but see its documentation for the assumptions
  this makes), or \`"outgroup"\` (root using \`outgroup\`).

- outgroup:

  One or more node IDs (matching whichever ID column \`pairwise\` uses)
  to root on, when \`root = "outgroup"\`. Ignored (with a warning) for
  any other \`root\`.

- on_missing:

  What to do if \`pairwise\` has missing (\`NA\`) distances for some
  pair(s) – as e.g. \[get_pairwise_geo_distance()\] records for
  societies with no land route, or \[get_pairwise_language_distance()\]
  for languages on different trees. \`"drop"\` (the default) repeatedly
  excludes whichever node is involved in the most remaining missing
  distances until none are left, with a warning listing what was dropped
  (erroring if fewer than 3 nodes would remain); \`"error"\` stops
  immediately instead, naming the affected nodes.

- tip_label:

  For a \`soc_id_1\`/\`soc_id_2\`-keyed \`pairwise\`: \`"id"\` (the
  default) labels tips with the raw \`soc_id\`, \`"name"\` looks up and
  uses each society's name instead (via \[dp_societies()\],
  disambiguating with the \`soc_id\` in parentheses if any names
  collide). Ignored (with a warning) for a \`group_1\`/\`group_2\`-keyed
  \`pairwise\`, where there's no name to look up.

- ...:

  Further arguments passed to \[ape::plot.phylo()\] (e.g. \`type =
  "fan"\`, \`cex\`, \`tip.color\`), overriding this function's defaults
  (\`type = "unrooted"\` when \`root = "none"\`, \`"phylogram"\`
  otherwise).

## Value

Invisibly, the \`"phylo"\` tree object (from ape) that was plotted –
capture it to inspect further, re-plot with different
\[ape::plot.phylo()\] options, or save it (e.g. \`ape::write.tree(tree,
"tree.nwk")\`).

## Examples

``` r
if (FALSE) { # \dontrun{
d <- get_pairwise_geo_distance(
  dp_societies(region = "Southern Africa")$soc_id, method = "great_circle"
)
plot_distance_tree(d, root = "midpoint")
plot_distance_tree(d, root = "outgroup", outgroup = "B72")

fst <- get_pairwise_cultural_FST(
  dp_societies(lang_family = c("Indo-European", "Afro-Asiatic", "Austronesian"))$soc_id,
  group = "lang_family", category = contains("Subsistence")
)
plot_distance_tree(fst$overall, distance_col = "value", method = "upgma")
} # }
```
