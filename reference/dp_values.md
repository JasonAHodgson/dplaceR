# Look up raw coded values

Filter the long-format D-PLACE data table (\[dplace_values\]) by
variable and/or society. For an analysis-ready table that also joins in
society information and (for categorical/ordinal variables) code labels,
use \[dp_variable_data()\] instead.

## Usage

``` r
dp_values(var_id = NULL, soc_id = NULL)
```

## Arguments

- var_id:

  Optional character vector of variable ID(s) to filter to. Also accepts
  a data frame/tibble with a \`var_id\` column, from which the column is
  used automatically.

- soc_id:

  Optional character vector of society ID(s) to filter to. Also accepts
  a data frame/tibble with a \`soc_id\` column, from which the column is
  used automatically.

## Value

A tibble of values (see \[dplace_values\] for column definitions).

## Examples

``` r
dp_values(var_id = "EA202", soc_id = "Sa1")
#> # A tibble: 1 × 8
#>   id        soc_id var_id value code_id  year source admin_comment
#>   <chr>     <chr>  <chr>  <chr> <chr>   <int> <chr>  <chr>        
#> 1 ea-121219 Sa1    EA202  NA    NA         NA NA     NA           
```
