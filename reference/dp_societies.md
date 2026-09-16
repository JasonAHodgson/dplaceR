# Browse or filter D-PLACE societies

Browse or filter D-PLACE societies

## Usage

``` r
dp_societies(
  glottocode = NULL,
  region = NULL,
  soc_id = NULL,
  xd_id = NULL,
  lang_family = NULL,
  lang_family_id = NULL,
  type = "society"
)
```

## Arguments

- glottocode:

  Optional character vector of Glottocodes to filter to, or
  \[contains()\] for a partial/regex match.

- region:

  Optional character vector of regions to filter to (matched exactly
  against the \`region\` column; see
  \`unique(dplace_societies\$region)\` for valid values), or
  \[contains()\] for a partial/regex match – e.g. \`region =
  contains("Africa")\`, since D-PLACE splits Africa into several regions
  with no single \`"Africa"\` value.

- soc_id:

  Optional character vector of society IDs to filter to, or
  \[contains()\] for a partial/regex match. Also accepts a data
  frame/tibble with a \`soc_id\` column (e.g. an earlier
  \`dp_societies()\` result passed straight through), from which the
  column is used automatically.

- xd_id:

  Optional character vector of cross-dataset ID(s) to filter to, or
  \[contains()\] for a partial/regex match – see
  \[get_related_societies()\] for finding a society's \`xd_id\` in the
  first place. Most societies have no \`xd_id\` (\`NA\`) and so never
  match.

- lang_family:

  Optional character vector of top-level language family name(s) to
  filter to (e.g. \`"Indo-European"\`, \`"Austronesian"\`), or
  \[contains()\] for a partial/regex match – see
  \[dp_lang_family_list()\] for the full list of available families. An
  isolate (e.g. \`"Zuni"\`) is its own top-level family. Named
  \`lang_family\` (not plain \`family\`) to avoid clashing with
  D-PLACE's own "family" cultural/kinship variables, which mean
  something unrelated.

- lang_family_id:

  Optional character vector of top-level language family Glottocode(s)
  to filter to (e.g. \`"indo1319"\` for Indo-European), or
  \[contains()\] for a partial/regex match – more stable than
  \`lang_family\` across any future family renaming.

- type:

  Character; which row types to include. Defaults to \`"society"\`
  (societies with coded cultural data). Use \`NULL\` to also include
  \`"languoid"\` rows (language varieties that appear only in a
  phylogeny, with no coded data of their own). Does not support
  \[contains()\].

## Value

A tibble of societies, one row per society (see \[dplace_societies\] for
column definitions).

## Examples

``` r
dp_societies(region = "Southern Africa")
#> # A tibble: 47 × 14
#>    soc_id        name        latitude longitude glottocode iso_code region type 
#>    <chr>         <chr>          <dbl>     <dbl> <chr>      <chr>    <chr>  <chr>
#>  1 B72           !Kung          -20        21.2 juho1239   NA       South… soci…
#>  2 B73           Naron          -21.6      21.6 naro1249   NA       South… soci…
#>  3 B79           /Xam           -31.5      19.8 xamm1241   NA       South… soci…
#>  4 B68           Hai//om        -18.6      16.1 haio1238   NA       South… soci…
#>  5 B74           G/wi           -22.5      23.4 gwii1239   NA       South… soci…
#>  6 B75           Kua            -22.9      24.4 kuaa1238   NA       South… soci…
#>  7 B76           !Ko            -23.9      22.2 huaa1248   NA       South… soci…
#>  8 B77           /'Auni-Kho…    -27.4      19.8 nuuu1241   NA       South… soci…
#>  9 B78           //Xegwi        -26.3      30.2 xegw1238   NA       South… soci…
#> 10 CARNEIRO4_016 Venda          -23        30   vend1245   NA       South… soci…
#> # ℹ 37 more rows
#> # ℹ 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>
dp_societies(region = contains("Africa"))
#> # A tibble: 707 × 14
#>    soc_id name    latitude longitude glottocode iso_code region            type 
#>    <chr>  <chr>      <dbl>     <dbl> <chr>      <chr>    <chr>             <chr>
#>  1 B72    !Kung     -20         21.2 juho1239   NA       Southern Africa   soci…
#>  2 B70    Dorobo      0         36   okie1245   NA       East Tropical Af… soci…
#>  3 B65    Mbuti       1.54      28.6 bila1255   NA       West-Central Tro… soci…
#>  4 B73    Naron     -21.6       21.6 naro1249   NA       Southern Africa   soci…
#>  5 B79    /Xam      -31.5       19.8 xamm1241   NA       Southern Africa   soci…
#>  6 B69    Hadza      -3.82      35.3 hadz1240   NA       East Tropical Af… soci…
#>  7 B60    Aka         2         17   base1242   NA       West-Central Tro… soci…
#>  8 B61    Bayaka      3.58      17.8 beka1240   NA       West-Central Tro… soci…
#>  9 B62    Bambote    -6.64      28.3 holo1240   NA       West-Central Tro… soci…
#> 10 B63    Baka        2.39      15.3 baka1272   NA       West-Central Tro… soci…
#> # ℹ 697 more rows
#> # ℹ 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>
dp_societies(glottocode = "juho1239")
#> # A tibble: 6 × 14
#>   soc_id        name         latitude longitude glottocode iso_code region type 
#>   <chr>         <chr>           <dbl>     <dbl> <chr>      <chr>    <chr>  <chr>
#> 1 B72           !Kung           -20        21.2 juho1239   NA       South… soci…
#> 2 CARNEIRO4_092 !Kung           -20        21   juho1239   NA       South… soci…
#> 3 CARNEIRO6_067 !Kung           -20        21   juho1239   NA       South… soci…
#> 4 CCMCjuho1239  South-Easte…    -19.7      20.8 juho1239   NA       South… soci…
#> 5 Aa1           !Kung           -20        21   juho1239   NA       South… soci…
#> 6 SCCS2         !Kung           -19.8      20.6 juho1239   NA       South… soci…
#> # ℹ 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>
dp_societies(xd_id = "xd1") # !Kung, coded independently by 3 datasets
#> # A tibble: 3 × 14
#>   soc_id name  latitude longitude glottocode iso_code region          type   
#>   <chr>  <chr>    <dbl>     <dbl> <chr>      <chr>    <chr>           <chr>  
#> 1 B72    !Kung    -20        21.2 juho1239   NA       Southern Africa society
#> 2 Aa1    !Kung    -20        21   juho1239   NA       Southern Africa society
#> 3 SCCS2  !Kung    -19.8      20.6 juho1239   NA       Southern Africa society
#> # ℹ 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>
dp_societies(lang_family = "Indo-European")
#> # A tibble: 167 × 14
#>    soc_id        name        latitude longitude glottocode iso_code region type 
#>    <chr>         <chr>          <dbl>     <dbl> <chr>      <chr>    <chr>  <chr>
#>  1 B10           Vedda           8.59     81.2  vedd1240   NA       India… soci…
#>  2 CARNEIRO4_002 Ancient Ro…    41.9      12.5  lati1261   NA       South… soci…
#>  3 CARNEIRO4_007 Kingdom of…    42.6      -5.57 leon1250   NA       South… soci…
#>  4 CARNEIRO4_008 Vikings        59        11.1  oldn1244   NA       North… soci…
#>  5 CARNEIRO4_072 Kamar          20.5      81.9  kama1350   NA       India… soci…
#>  6 CARNEIRO4_089 Vedda           8        81    vedd1240   NA       India… soci…
#>  7 CARNEIRO4_103 Hazara         35        66    haza1239   NA       Weste… soci…
#>  8 CARNEIRO6_001 Ancient Ro…    41.9      12.5  lati1261   NA       South… soci…
#>  9 CARNEIRO6_002 Ancient In…    25.6      85.1  clas1258   NA       India… soci…
#> 10 CARNEIRO6_004 Classical …    38        23.7  anci1242   NA       South… soci…
#> # ℹ 157 more rows
#> # ℹ 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>
dp_societies(lang_family = contains("Austro")) # Austronesian AND Austroasiatic
#> # A tibble: 272 × 14
#>    soc_id name             latitude longitude glottocode iso_code region   type 
#>    <chr>  <chr>               <dbl>     <dbl> <chr>      <chr>    <chr>    <chr>
#>  1 B9     Semang               5.86     101   kens1248   NA       Malesia  soci…
#>  2 B3     Anak Dalam          -3.04     103.  kubu1239   NA       Malesia  soci…
#>  3 B1     Punan                3        114   west2563   NA       Malesia  soci…
#>  4 B2     Palawan Batak       10.0      119.  bata1301   NA       Malesia  soci…
#>  5 B7     Ayta (Pinatubo)     15.5      120.  boto1242   NA       Malesia  soci…
#>  6 B12    Agta (Casiguran)    17.3      122.  casi1235   NA       Malesia  soci…
#>  7 B13    Agta (Isabela)      17.5      122.  agta1234   NA       Malesia  soci…
#>  8 B14    Agta (Cagayan)      17.8      122.  cent2084   NA       Malesia  soci…
#>  9 B16    Mlabri              18.4      100.  mlab1235   NA       Indo-Ch… soci…
#> 10 B18    Birhor              23.4       84.4 birh1242   NA       Indian … soci…
#> # ℹ 262 more rows
#> # ℹ 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>
```
