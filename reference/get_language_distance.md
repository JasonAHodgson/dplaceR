# Language (branch-length) distance from a point or society to a list of societies

Computes the linguistic distance from a single reference point – either
an existing D-PLACE society or an arbitrary Glottocode – to each society
in a list, as the branch-length ("patristic") distance between their
languages on a bundled D-PLACE language tree (see
\[dp_trees()\]/\[dp_tree()\]). For distances between all pairs within a
set of societies, use \[get_pairwise_language_distance()\] instead; it
shares this function's matching rules, units caveat, and \`cross_tree\`/
\`multiplier\` semantics.

## Usage

``` r
get_language_distance(point, soc_id, cross_tree, multiplier = 2)
```

## Arguments

- point:

  Either a single D-PLACE society ID (character, see
  \[dp_societies()\]), or a single Glottocode that appears in a bundled
  language tree (see \[dp_trees()\]) – useful for referencing a language
  with no D-PLACE society attached.

- soc_id:

  Character vector of one or more D-PLACE society IDs to compute the
  distance to (see \[dp_societies()\]). Unknown IDs, and societies whose
  language can't be matched to any bundled tree, are dropped with a
  warning.

- cross_tree:

  One of \`"na"\` or \`"join_root"\` – see
  \[get_pairwise_language_distance()\]. There is no default; it must be
  supplied explicitly. \`"join_root"\` currently errors (not implemented
  yet).

- multiplier:

  Reserved for a future \`cross_tree = "join_root"\` implementation;
  currently unused. Default \`2\`.

## Value

A tibble with one row per society in \`soc_id\` that has a matchable
language: \`soc_id\` and \`language_distance\` (branch-length units of
whichever tree the pair was computed on – see the units caveat in
\[get_pairwise_language_distance()\]). A society whose language is on a
different tree from \`point\` gets \`language_distance = NA\` under
\`cross_tree = "na"\`, with a warning summarizing how many such
societies were found, rather than failing the whole call.

## Details

See \[get_pairwise_language_distance()\] for full details on: how
societies are matched to tree tips (\`glottocode\`, falling back to
\`language_level_glottocodes\` when single-valued); the important caveat
that branch length units are NOT consistent across D-PLACE's bundled
trees (arbitrary Glottolog classification depth for most, real
calibrated dates for a minority – check \`dp_trees()\`'s \`source\`
column); and the \`cross_tree\` options (\`"na"\`, implemented;
\`"join_root"\`, not implemented yet).

## Examples

``` r
if (FALSE) { # \dontrun{
get_language_distance("B72", c("B73", "B79"), cross_tree = "na")
get_language_distance("naro1249", c("B72", "B73", "B79"), cross_tree = "na")
} # }
```
