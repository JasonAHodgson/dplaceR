# Browse D-PLACE language phylogenies

Lists the phylogenetic/classification trees available in D-PLACE. Use
\[dp_tree()\] to load a specific tree.

## Usage

``` r
dp_trees(tree_id = NULL, contribution_id = NULL)
```

## Arguments

- tree_id:

  Optional character vector of tree IDs to filter to (usually
  Glottocodes identifying a language family/group).

- contribution_id:

  Optional character vector of contribution IDs to filter to (e.g.
  \`"glottolog_glottolog"\`).

## Value

A tibble of tree metadata (see \[dplace_trees\] for column definitions),
excluding the \`nexus\` column so it stays easy to browse – use
\[dp_tree()\] to get the actual tree.

## Examples

``` r
dp_trees()
#> # A tibble: 114 × 7
#>    tree_id  name   is_rooted tree_type branch_length_unit source contribution_id
#>    <chr>    <chr>  <chr>     <chr>     <lgl>              <chr>  <chr>          
#>  1 abkh1242 summa… Yes       summary   NA                 glott… abkh1242       
#>  2 surm1244 summa… Yes       summary   NA                 glott… surm1244       
#>  3 cent2225 summa… Yes       summary   NA                 glott… cent2225       
#>  4 otom1299 summa… Yes       summary   NA                 glott… otom1299       
#>  5 miwo1274 summa… Yes       summary   NA                 glott… miwo1274       
#>  6 utoa1244 summa… Yes       summary   NA                 glott… utoa1244       
#>  7 kadu1256 summa… Yes       summary   NA                 glott… kadu1256       
#>  8 sout2845 summa… Yes       summary   NA                 glott… sout2845       
#>  9 mong1349 summa… Yes       summary   NA                 glott… mong1349       
#> 10 drav1251 summa… Yes       summary   NA                 glott… drav1251       
#> # ℹ 104 more rows
```
