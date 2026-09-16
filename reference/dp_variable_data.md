# Build an analysis-ready table for one or more variables

Joins the coded values for the given variable(s) to society information
(name, coordinates, glottocode) and, for categorical/ordinal variables,
to human-readable code labels.

## Usage

``` r
dp_variable_data(var_id, society_info = TRUE)
```

## Arguments

- var_id:

  Character vector of variable ID(s). Also accepts a data frame/tibble
  with a \`var_id\` column, from which the column is used automatically.

- society_info:

  Logical; if \`TRUE\` (the default), join in \`name\`, \`latitude\`,
  \`longitude\`, \`glottocode\`, and \`region\` from
  \[dplace_societies\].

## Value

A tibble with one row per society/variable value, including: \`soc_id\`,
\`var_id\`, \`value\` (raw), \`code_id\`, \`code_label\` (\`NA\` for
continuous variables), \`year\`, \`source\`, and (if \`society_info =
TRUE\`) \`society_name\`, \`latitude\`, \`longitude\`, \`glottocode\`,
\`region\`.

## Examples

``` r
dp_variable_data("B035")
#> # A tibble: 339 × 12
#>    soc_id var_id value     code_id code_label  year source society_name latitude
#>    <chr>  <chr>  <chr>     <chr>   <chr>      <int> <chr>  <chr>           <dbl>
#>  1 B1     B035   Endogamo… B035-4  Endogamou…  1970 avadh… Punan            3   
#>  2 B53    B035   Endogamo… B035-4  Endogamou…  1900 bird1… Alacaluf       -49.6 
#>  3 B69    B035   Endogamo… B035-4  Endogamou…  1910 bleek… Hadza           -3.82
#>  4 B14    B035   Endogamo… B035-4  Endogamou…  1924 goodm… Agta (Cagay…    17.8 
#>  5 B44    B035   Endogamo… B035-4  Endogamou…  1968 stear… Yuqui          -16.5 
#>  6 B99    B035   Endogamo… B035-4  Endogamou…  1900 stann… Mulluk         -13.6 
#>  7 B193   B035   Endogamo… B035-4  Endogamou…  1800 bolto… Karankawa       28.4 
#>  8 B105   B035   Endogamo… B035-4  Endogamou…  1900 birds… Mamu           -17.6 
#>  9 B183   B035   Endogamo… B035-4  Endogamou…  1860 giffo… Atsugewi        40.8 
#> 10 B49    B035   Endogamo… B035-4  Endogamou…  1954 kozak… Héta           -23.5 
#> # ℹ 329 more rows
#> # ℹ 3 more variables: longitude <dbl>, glottocode <chr>, region <chr>
```
