# Load a D-PLACE language phylogeny

Load a D-PLACE language phylogeny

## Usage

``` r
dp_tree(tree_id, raw = FALSE)
```

## Arguments

- tree_id:

  A single tree ID (see \[dp_trees()\]).

- raw:

  Logical; if \`TRUE\`, return the raw NEXUS text instead of a parsed
  tree. Useful if you don't have the ape package installed, or want to
  parse the tree yourself.

## Value

If \`raw = FALSE\` (the default), an object of class \`"phylo"\` (from
the ape package), with tip labels given as Glottocodes. If \`raw =
TRUE\`, a single character string of NEXUS-format tree data.

## Examples

``` r
# \donttest{
tr <- dp_tree("abkh1242")
if (requireNamespace("ape", quietly = TRUE)) {
  ape::plot.phylo(tr)
}

# }
```
