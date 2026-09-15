# Language phylogenies in D-PLACE

One row per phylogenetic/classification tree available in D-PLACE, with
the tree itself stored as raw NEXUS text.

## Usage

``` r
dplace_trees
```

## Format

A tibble with the following columns:

- tree_id:

  Character. Usually a Glottocode identifying the language family/group
  the tree covers.

- name:

  Character. Tree name (often \`"summary"\`).

- is_rooted:

  Character. \`"Yes"\`/\`"No"\`.

- tree_type:

  Character. e.g. \`"summary"\`.

- branch_length_unit:

  Character. Unit for branch lengths, if any.

- source:

  Character. Where the tree comes from, e.g. \`"glottolog_glottolog"\`
  or \`"dplace-phylogeny-atkinson2006"\`.

- contribution_id:

  Character. For trees with \`source\` other than
  \`"glottolog_glottolog"\`, joins to \[dplace_contributions\]. For
  plain Glottolog classification trees (\`source ==
  "glottolog_glottolog"\`) D-PLACE has no separate contribution record,
  so this repeats the tree's Glottocode instead and will not match a row
  in \[dplace_contributions\].

- nexus:

  Character. The full tree in NEXUS format. Use \[dp_tree()\] to parse
  this into an \`ape::phylo\` object.

## Source

D-PLACE CLDF dataset, <https://github.com/D-PLACE/dplace-cldf>. See
\[dplace_meta\] for the exact release bundled with this package.

## See also

\[dp_trees()\], \[dp_tree()\]
