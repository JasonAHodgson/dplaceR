# Search D-PLACE variables by keyword

A thin, more discoverable wrapper around \`dp_variables(search =
keyword)\`.

## Usage

``` r
dp_search_variables(keyword)
```

## Arguments

- keyword:

  A search term matched (case-insensitively) against variable names and
  descriptions.

## Value

A tibble of matching variables (see \[dplace_variables\] for column
definitions).

## Examples

``` r
dp_search_variables("marriage")
#> # A tibble: 78 × 7
#>    var_id        name           description category type  unit  contribution_id
#>    <chr>         <chr>          <chr>       <chr>    <chr> <chr> <chr>          
#>  1 B020          Age of males … Mean age (… Demogra… Cont… years dplace-dataset…
#>  2 B021          Age of female… Mean age (… Demogra… Cont… years dplace-dataset…
#>  3 B035          Community mar… The preval… Communi… Cate… NA    dplace-dataset…
#>  4 CARNEIRO4_124 Social segmen… Social seg… Social … Cate… NA    dplace-dataset…
#>  5 CARNEIRO6_188 Special taxes  Special ta… Economi… Cate… NA    dplace-dataset…
#>  6 CARNEIRO6_217 Social segmen… Social (ra… Social … Cate… NA    dplace-dataset…
#>  7 CARNEIRO6_224 Bride price, … Marriage f… Social … Cate… NA    dplace-dataset…
#>  8 CARNEIRO6_226 Marriage cele… Marriage c… Social … Cate… NA    dplace-dataset…
#>  9 CARNEIRO6_227 Marriages per… Marriages … Social … Cate… NA    dplace-dataset…
#> 10 CARNEIRO6_370 Laws governin… Laws gover… Law and… Cate… NA    dplace-dataset…
#> # ℹ 68 more rows
```
