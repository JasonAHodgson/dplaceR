# Browse D-PLACE dataset contributions (sources)

Browse D-PLACE dataset contributions (sources)

## Usage

``` r
dp_contributions(contribution_id = NULL, type = NULL)
```

## Arguments

- contribution_id:

  Optional character vector of contribution IDs to filter to.

- type:

  Optional character vector restricting to contribution type(s), e.g.
  \`"dataset"\` or \`"phylogeny"\`.

## Value

A tibble of contributions (see \[dplace_contributions\] for column
definitions).

## Examples

``` r
dp_contributions(type = "dataset")
#> # A tibble: 14 × 7
#>    contribution_id           name   description contributor citation doi   type 
#>    <chr>                     <chr>  <chr>       <chr>       <chr>    <chr> <chr>
#>  1 dplace-dataset-binford    D-PLA… The Binfor… Binford, L… "Lewis … 10.5… data…
#>  2 dplace-dataset-carneiro4  D-PLA… NA          Carneiro, … "Robert… 10.5… data…
#>  3 dplace-dataset-carneiro6  D-PLA… NA          Carneiro, … "Robert… 10.5… data…
#>  4 dplace-dataset-ccmc       D-PLA… The Expand… Bertolo, M… "Mila B… 10.5… data…
#>  5 dplace-dataset-ea         D-PLA… The Ethnog… Murdock, G… "Murdoc… 10.5… data…
#>  6 dplace-dataset-ecoclimate D-PLA… Dataset Ba… MS, Lima-R… "Lima-R… 10.5… data…
#>  7 dplace-dataset-gmted2010  D-PLA… Global Mul… Center, Ea… "Earth … 10.5… data…
#>  8 dplace-dataset-gshhs      D-PLA… Distance t… Wessel, P.… "P. Wes… 10.5… data…
#>  9 dplace-dataset-jenkins    D-PLA… Animal ric… Jenkins, C… "Jenkin… 10.5… data…
#> 10 dplace-dataset-kreft      D-PLA… NA          H., Kreft … "Kreft … 10.5… data…
#> 11 dplace-dataset-modis      D-PLA… Net Primar… TERRA/MODI… "NASA T… 10.5… data…
#> 12 dplace-dataset-sccs       D-PLA… NA          Murdock, G… "Murdoc… 10.5… data…
#> 13 dplace-dataset-teow       D-PLA… This datas… Olson, D. … "Olson,… 10.5… data…
#> 14 dplace-dataset-wnai       D-PLA… The Wester… Jorgensen,… "Jorgen… 10.5… data…
```
