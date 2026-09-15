# How to cite dplaceR, D-PLACE, and the bundled data snapshot

Prints (and invisibly returns) how to cite dplaceR itself, alongside the
citation for D-PLACE and the version/licence of the CLDF snapshot
bundled with this package. Cite the individual source dataset(s) too –
see \[dp_contributions()\] for their citations.

## Usage

``` r
dp_citation()
```

## Value

Invisibly, the one-row \[dplace_meta\] tibble.

## Examples

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
