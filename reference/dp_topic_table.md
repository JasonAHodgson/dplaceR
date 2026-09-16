# Count how many variables carry each topic

A two-column summary of \[dp_topic_list()\]: how many variables (see
\[dp_topics()\]) are tagged with each topic, so you can see at a glance
which topics are broad and which are narrow before filtering by one.

## Usage

``` r
dp_topic_table(type = NULL)
```

## Arguments

- type:

  Optional character vector restricting to variable type(s):
  \`"Categorical"\`, \`"Ordinal"\`, and/or \`"Continuous"\`. Passed
  straight to \[dp_topics()\]/\[dp_topic_list()\] – see there for what
  it means to filter topics by type. Topics with no variable of the
  given type(s) are dropped entirely rather than shown with
  \`n_variables = 0\`.

## Value

A tibble with one row per topic, in the same order as
\[dp_topic_list()\]: \`topic\` and \`n_variables\` (the number of
variables whose \`category\` includes that topic – see \[dp_topics()\],
including its note on near-duplicate topic spellings that are counted
separately here too).

## Examples

``` r
dp_topic_table()
#> # A tibble: 56 × 2
#>    topic                  n_variables
#>    <chr>                        <int>
#>  1 Anthropometry                    4
#>  2 Architecture                    62
#>  3 Ceramics and Art                33
#>  4 Ceremony                        18
#>  5 Childhood                      352
#>  6 Class                           13
#>  7 Climate                         10
#>  8 Clothing                        16
#>  9 Community                       20
#> 10 Community organization          86
#> # ℹ 46 more rows
# most common topics first
dp_topic_table()[order(-dp_topic_table()$n_variables), ]
#> # A tibble: 56 × 2
#>    topic       n_variables
#>    <chr>             <int>
#>  1 Gender              589
#>  2 Life cycle          536
#>  3 Labour              480
#>  4 Household           381
#>  5 Childhood           352
#>  6 Economy             342
#>  7 Politics            313
#>  8 Subsistence         294
#>  9 Kinship             280
#> 10 Marriage            249
#> # ℹ 46 more rows
dp_topic_table(type = "Continuous")
#> # A tibble: 23 × 2
#>    topic                  n_variables
#>    <chr>                        <int>
#>  1 Anthropometry                    4
#>  2 Childhood                        6
#>  3 Climate                         10
#>  4 Community organization          10
#>  5 Data Quality                    14
#>  6 Death                            8
#>  7 Demography                       7
#>  8 Ecology                         28
#>  9 Economy                          3
#> 10 Gender                          11
#> # ℹ 13 more rows
```
