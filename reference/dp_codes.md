# Look up codes for categorical/ordinal D-PLACE variables

Look up codes for categorical/ordinal D-PLACE variables

## Usage

``` r
dp_codes(var_id)
```

## Arguments

- var_id:

  Character vector of variable ID(s) to get codes for.

## Value

A tibble of codes, ordered by \`ord\` within each variable (see
\[dplace_codes\] for column definitions). Returns zero rows (with a
warning) for variables that have no codes, e.g. continuous variables.

## Examples

``` r
dp_codes("B035")
#> # A tibble: 6 × 5
#>   code_id var_id name                 description            ord
#>   <chr>   <chr>  <chr>                <chr>                <int>
#> 1 B035-1  B035   Exogamous            Exogamous                1
#> 2 B035-2  B035   Exogamous clan       Exogamous clan           2
#> 3 B035-3  B035   Agamous              Agamous                  3
#> 4 B035-4  B035   Endogamous demed     Endogamous demed         4
#> 5 B035-5  B035   Endogamous segmented Endogamous segmented     5
#> 6 B035-NA B035   Missing data         Missing data            99
```
