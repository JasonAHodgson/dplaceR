# dplaceR

dplaceR provides an R interface to [D-PLACE](https://d-place.org)
(Database of Places, Language, Culture and Environment), a
cross-cultural database linking ethnographic, linguistic, environmental,
and geographic information for societies around the world.

A snapshot of the D-PLACE [CLDF](https://cldf.clld.org/) dataset is
bundled with the package, so no internet connection is needed after
installation, and results are reproducible across dplaceR versions. See
[`dp_citation()`](https://jasonahodgson.github.io/dplaceR/reference/dp_citation.md)
for exactly which release is bundled.

## Installation

You can install the development version of dplaceR from
[GitHub](https://github.com/) with:

``` r

# install.packages("remotes")
remotes::install_github("jasonahodgson/dplaceR")
```

## Example

Browse societies and variables, look up the coded values for a variable,
and join them to society information in one step:

``` r

library(dplaceR)

# Societies in a region
dp_societies(region = "Southern Africa")
#> # A tibble: 47 x 14
#>    soc_id        name        latitude longitude glottocode iso_code region type 
#>    <chr>         <chr>          <dbl>     <dbl> <chr>      <chr>    <chr>  <chr>
#>  1 B72           !Kung          -20        21.2 juho1239   <NA>     South~ soci~
#>  2 B73           Naron          -21.6      21.6 naro1249   <NA>     South~ soci~
#>  3 B79           /Xam           -31.5      19.8 xamm1241   <NA>     South~ soci~
#>  4 B68           Hai//om        -18.6      16.1 haio1238   <NA>     South~ soci~
#>  5 B74           G/wi           -22.5      23.4 gwii1239   <NA>     South~ soci~
#>  6 B75           Kua            -22.9      24.4 kuaa1238   <NA>     South~ soci~
#>  7 B76           !Ko            -23.9      22.2 huaa1248   <NA>     South~ soci~
#>  8 B77           /'Auni-Kho~    -27.4      19.8 nuuu1241   <NA>     South~ soci~
#>  9 B78           //Xegwi        -26.3      30.2 xegw1238   <NA>     South~ soci~
#> 10 CARNEIRO4_016 Venda          -23        30   vend1245   <NA>     South~ soci~
#> # i 37 more rows
#> # i 6 more variables: main_focal_year <int>, language_level_glottocodes <chr>,
#> #   contribution_id <chr>, xd_id <chr>, lang_family_id <chr>, lang_family <chr>

# Find variables about a topic
dp_search_variables("descent")
#> # A tibble: 14 x 7
#>    var_id        name           description category type  unit  contribution_id
#>    <chr>         <chr>          <chr>       <chr>    <chr> <chr> <chr>          
#>  1 CARNEIRO6_223 Occupational ~ "Occupatio~ Social ~ Cate~ <NA>  dplace-dataset~
#>  2 CARNEIRO6_326 (Semi)divine ~ "Ruler is ~ Politic~ Cate~ <NA>  dplace-dataset~
#>  3 EA022         Secondary cog~ "The prese~ Kinship  Cate~ <NA>  dplace-dataset~
#>  4 EA043         Descent: majo~ "Major mod~ Kinship  Cate~ <NA>  dplace-dataset~
#>  5 SCCS70        Descent - Mem~ "Murdock, ~ Communi~ Cate~ <NA>  dplace-dataset~
#>  6 SCCS71        Descent Group~ "Murdock, ~ Communi~ Cate~ <NA>  dplace-dataset~
#>  7 SCCS247       Descent: majo~ "Gray (199~ Kinship  Cate~ (bla~ dplace-dataset~
#>  8 SCCS696       Matrilineal D~ "Whyte, M.~ Gender   Ordi~ <NA>  dplace-dataset~
#>  9 SCCS836       Rule of Desce~ "Murdock, ~ Kinship  Cate~ <NA>  dplace-dataset~
#> 10 SCCS1193      Exogamous Non~ "Kin Avoid~ Kinship  Cate~ <NA>  dplace-dataset~
#> 11 SCCS1753      Depth of Unil~ "Lang, H. ~ Kinship~ Cate~ <NA>  dplace-dataset~
#> 12 WNAI311       Forms of desc~ "This is a~ Kinship~ Cate~ <NA>  dplace-dataset~
#> 13 WNAI312       Forms of kins~ "Kinship u~ Kinship~ Cate~ <NA>  dplace-dataset~
#> 14 WNAI313       Stipulated de~  <NA>       Kinship~ Cate~ <NA>  dplace-dataset~

# Codes for a categorical variable
dp_codes("B035")
#> # A tibble: 6 x 5
#>   code_id var_id name                 description            ord
#>   <chr>   <chr>  <chr>                <chr>                <int>
#> 1 B035-1  B035   Exogamous            Exogamous                1
#> 2 B035-2  B035   Exogamous clan       Exogamous clan           2
#> 3 B035-3  B035   Agamous              Agamous                  3
#> 4 B035-4  B035   Endogamous demed     Endogamous demed         4
#> 5 B035-5  B035   Endogamous segmented Endogamous segmented     5
#> 6 B035-NA B035   Missing data         Missing data            99

# Analysis-ready table: values + society info + code labels
dp_variable_data("B035")
#> # A tibble: 339 x 12
#>    soc_id var_id value     code_id code_label  year source society_name latitude
#>    <chr>  <chr>  <chr>     <chr>   <chr>      <int> <chr>  <chr>           <dbl>
#>  1 B1     B035   Endogamo~ B035-4  Endogamou~  1970 avadh~ "Punan"          3   
#>  2 B53    B035   Endogamo~ B035-4  Endogamou~  1900 bird1~ "Alacaluf"     -49.6 
#>  3 B69    B035   Endogamo~ B035-4  Endogamou~  1910 bleek~ "Hadza"         -3.82
#>  4 B14    B035   Endogamo~ B035-4  Endogamou~  1924 goodm~ "Agta (Caga~    17.8 
#>  5 B44    B035   Endogamo~ B035-4  Endogamou~  1968 stear~ "Yuqui"        -16.5 
#>  6 B99    B035   Endogamo~ B035-4  Endogamou~  1900 stann~ "Mulluk"       -13.6 
#>  7 B193   B035   Endogamo~ B035-4  Endogamou~  1800 bolto~ "Karankawa"     28.4 
#>  8 B105   B035   Endogamo~ B035-4  Endogamou~  1900 birds~ "Mamu"         -17.6 
#>  9 B183   B035   Endogamo~ B035-4  Endogamou~  1860 giffo~ "Atsugewi"      40.8 
#> 10 B49    B035   Endogamo~ B035-4  Endogamou~  1954 kozak~ "H\u00e9ta"    -23.5 
#> # i 329 more rows
#> # i 3 more variables: longitude <dbl>, glottocode <chr>, region <chr>
```

Language phylogenies are available too:

``` r

dp_trees()
#> # A tibble: 114 x 7
#>    tree_id  name   is_rooted tree_type branch_length_unit source contribution_id
#>    <chr>    <chr>  <chr>     <chr>     <lgl>              <chr>  <chr>          
#>  1 abkh1242 summa~ Yes       summary   NA                 glott~ abkh1242       
#>  2 surm1244 summa~ Yes       summary   NA                 glott~ surm1244       
#>  3 cent2225 summa~ Yes       summary   NA                 glott~ cent2225       
#>  4 otom1299 summa~ Yes       summary   NA                 glott~ otom1299       
#>  5 miwo1274 summa~ Yes       summary   NA                 glott~ miwo1274       
#>  6 utoa1244 summa~ Yes       summary   NA                 glott~ utoa1244       
#>  7 kadu1256 summa~ Yes       summary   NA                 glott~ kadu1256       
#>  8 sout2845 summa~ Yes       summary   NA                 glott~ sout2845       
#>  9 mong1349 summa~ Yes       summary   NA                 glott~ mong1349       
#> 10 drav1251 summa~ Yes       summary   NA                 glott~ drav1251       
#> # i 104 more rows

dp_tree("abkh1242")
#> 
#> Phylogenetic tree with 2 tips and 1 internal nodes.
#> 
#> Tip labels:
#>   abkh1244, kaba1278
#> 
#> Rooted; includes branch lengths.
```

## Citing dplaceR and D-PLACE

If you use dplaceR in published work, please cite the dplaceR package
itself, in addition to D-PLACE and the specific source dataset(s) your
variables come from:

``` r

citation("dplaceR")
#> If you use dplaceR in published work, please cite the package itself,
#> in addition to D-PLACE and the specific source dataset(s) your
#> variables come from (see dp_citation() and dp_contributions() for
#> those):
#> 
#>   Hodgson JA (2026). _dplaceR: An R Interface to the D-PLACE
#>   Cross-Cultural Database_. R package version 0.1.0,
#>   <https://jasonahodgson.github.io/dplaceR/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {dplaceR: An R Interface to the D-PLACE Cross-Cultural Database},
#>     author = {Jason A. Hodgson},
#>     year = {2026},
#>     note = {R package version 0.1.0},
#>     url = {https://jasonahodgson.github.io/dplaceR/},
#>   }
```

``` r

dp_citation()
#> dplaceR:
#>   Please cite the package itself alongside D-PLACE -- see
#>   citation("dplaceR") (Jason A. Hodgson, package author).
#> 
#> D-PLACE:
#>   Kirby, K.R., Gray, R.D., Greenhill, S.J., Jordan, F.M., Gomes-Ng, S., Bibiko, H-J., Blasi, D.E., Botero, C.A., Bowern, C., Ember, C.R., Leehr, D., Low, B.S., McCarter, J., Divale, W., Gavin, M.C. (2016). D-PLACE: A Global Database of Cultural, Linguistic and Environmental Diversity. PLoS ONE 11(7): e0158391.
#> 
#> Bundled snapshot: D-PLACE CLDF v3.3.0 (D-PLACE/dplace-cldf), prepared 2026-09-14
#> Data licence: CC-BY-NC-4.0 (D-PLACE data; see https://d-place.org)
#> Language family classification: Glottolog CLDF v5.3 (glottolog/glottolog-cldf) -- see dplace_societies's `lang_family`/`lang_family_id` columns.
#> 
#> Please also cite the specific source dataset(s) your variables come from -- see dp_contributions() for per-dataset citations.
```

``` r

dp_contributions(contribution_id = "dplace-dataset-binford")
#> # A tibble: 1 x 7
#>   contribution_id        name       description contributor citation doi   type 
#>   <chr>                  <chr>      <chr>       <chr>       <chr>    <chr> <chr>
#> 1 dplace-dataset-binford D-PLACE d~ The Binfor~ Binford, L~ "Lewis ~ 10.5~ data~
```
