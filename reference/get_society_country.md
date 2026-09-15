# Look up a society's country from its coordinates

Reverse-geocodes each society's recorded coordinates to a country name,
using the 'maps' package's bundled low-resolution world map
(\`maps::map.where()\`). D-PLACE itself doesn't record country – only
world region (\[dp_societies()\]'s \`region\` column, which spans
multiple countries), coordinates, and language codes – so this fills
that gap.

## Usage

``` r
get_society_country(soc_id)
```

## Arguments

- soc_id:

  Character vector of one or more D-PLACE society IDs (see
  \[dp_societies()\]). Unknown IDs, and societies with missing
  coordinates, are dropped with a warning.

## Value

A tibble with one row per society: \`soc_id\` and \`country\`
(character; \`NA\` where the coordinates didn't resolve to any mapped
country).

## Details

Because the underlying map is low-resolution, a society very close to a
border, coastline, or a small/disputed territory can resolve to the
wrong country, to a compound name like \`"UK:Great Britain"\` (the part
before the colon is used as \`country\`; a few small overseas
territories or exclaves are named this way in the 'maps' world
database), or to nothing at all (\`NA\`, with a warning) if the point
falls just outside every mapped polygon (common just offshore). Treat
the result as a convenient approximation, not authoritative for
borderline cases.

## Examples

``` r
if (FALSE) { # \dontrun{
get_society_country(c("B72", "CCMCamha1245"))
} # }
```
