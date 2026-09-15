# Count how many coded societies belong to each language family

A two-column summary of \[dp_lang_family_list()\]: how many \`type =
"society"\` rows (see \[dp_societies()\]) belong to each top-level
language family, so you can see at a glance which families are well
represented before filtering by one.

## Usage

``` r
dp_lang_family_table()
```

## Value

A tibble with one row per family, in the same order as
\[dp_lang_family_list()\]: \`lang_family\` and \`n_societies\` (the
number of coded societies belonging to that top-level family – see
\[dplace_societies\]'s \`lang_family\`/\`lang_family_id\` columns).
Societies with no \`lang_family\` (no \`glottocode\`) aren't counted
anywhere in this table, so \`sum(dp_lang_family_table()\$n_societies)\`
can be slightly less than \`nrow(dp_societies())\`.

## Examples

``` r
dp_lang_family_table()
#> # A tibble: 197 × 2
#>    lang_family             n_societies
#>    <chr>                         <int>
#>  1 Abkhaz-Adyge                      4
#>  2 Afro-Asiatic                    140
#>  3 Ainu                              4
#>  4 Algic                            85
#>  5 Alsea-Yaquina                     3
#>  6 Anim                              1
#>  7 Araucanian                        3
#>  8 Arawakan                         23
#>  9 Athabaskan-Eyak-Tlingit         104
#> 10 Atlantic-Congo                  400
#> # ℹ 187 more rows
# most represented families first
dp_lang_family_table()[order(-dp_lang_family_table()$n_societies), ]
#> # A tibble: 197 × 2
#>    lang_family             n_societies
#>    <chr>                         <int>
#>  1 Atlantic-Congo                  400
#>  2 Austronesian                    242
#>  3 Indo-European                   167
#>  4 Uto-Aztecan                     163
#>  5 Afro-Asiatic                    140
#>  6 Athabaskan-Eyak-Tlingit         104
#>  7 Algic                            85
#>  8 Salishan                         73
#>  9 Pama-Nyungan                     64
#> 10 Eskimo-Aleut                     54
#> # ℹ 187 more rows
```
