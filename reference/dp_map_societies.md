# Plot societies on a world map

Draws a world map (via ggplot2 and the 'maps' package's bundled
low-resolution world boundaries) with one point per society, optionally
coloured by another column – e.g. a variable's coded value, or the
\`geo_distance\` column from \[get_geo_distance()\], the
\`cult_distance\` column from \[get_cult_distance()\], or an \`n_match\`
column from either (or their pairwise counterparts), after joining in
coordinates with \[get_society_meta()\] if needed.

## Usage

``` r
dp_map_societies(data, color = NULL, label = FALSE, point_size = 2)
```

## Arguments

- data:

  Either a character vector of D-PLACE society IDs, or a data
  frame/tibble. If it doesn't already have \`latitude\`/\`longitude\`
  columns, it must have a \`soc_id\` column, which is used to look them
  up via \[get_society_meta()\]. Rows with missing coordinates are
  dropped with a warning.

- color:

  Optional; the name of a column in \`data\` to map to point colour
  (e.g. \`"region"\`, or a variable's value). Left plain (a single
  colour) if omitted.

- label:

  Logical; if \`TRUE\`, label each point with its \`soc_id\` (only if
  \`data\` has one). Default \`FALSE\`.

- point_size:

  Point size, passed to \`ggplot2::geom_point()\`. Default \`2\`.

## Value

A \`ggplot\` object; print it to display, or add further \`ggplot2\`
layers/theming to customize it.

## Examples

``` r
if (FALSE) { # \dontrun{
dp_map_societies(c("B72", "B73", "B79"))
dp_map_societies(dp_societies(region = "Southern Africa"), color = "region")
} # }
```
