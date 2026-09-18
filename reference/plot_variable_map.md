# Plot a coded variable on a map, one point per society

A variable-aware companion to \[dp_map_societies()\]: given a chosen
subset of societies and a single D-PLACE variable, plots each society on
a world map coloured by its coded value for that variable – e.g.
community marriage organization (\`"B035"\`) across a set of societies.
Where \[dp_map_societies()\] colours by any column you already have,
\`plot_variable_map()\` looks the variable's data up for you and handles
the details specific to D-PLACE's coded data: collapsing a society's
more than one recorded observation to a single value (as in
\[get_society_data()\]'s \`format = "wide"\`), excluding D-PLACE's
dedicated "no data" sentinel code from counting as a real observation
(as in \[get_cult_distance()\] and friends), and, for an \`"Ordinal"\`
variable, ordering the color scale by the codes' rank (\`ord\`, see
\[dp_codes()\]) rather than alphabetically.

## Usage

``` r
plot_variable_map(
  soc_id,
  var_id,
  drop_na = TRUE,
  label = FALSE,
  point_size = 2,
  zoom = TRUE
)
```

## Arguments

- soc_id:

  Character vector of D-PLACE society IDs to plot. Also accepts a data
  frame/tibble with a \`soc_id\` column, from which the column is used
  automatically.

- var_id:

  A single D-PLACE variable ID (see \[dp_variables()\] or
  \[dp_search_variables()\] to find one) – one map, one variable; call
  this again for another.

- drop_na:

  Logical; societies in \`soc_id\` with no usable coded value for
  \`var_id\` (either genuinely uncoded, or only carrying D-PLACE's
  missing-data sentinel) are always identified, with a warning naming
  how many. If \`TRUE\` (the default), they're then dropped from the
  plot entirely; if \`FALSE\`, they're kept and shown as \`NA\` (grey,
  by ggplot2's default), which can itself be useful to see where your
  selection's coverage gaps are.

- label:

  Logical; if \`TRUE\`, label each point with its \`soc_id\`. Passed
  straight to \[dp_map_societies()\]. Default \`FALSE\`.

- point_size:

  Point size, passed to \[dp_map_societies()\] (and on to
  \`ggplot2::geom_point()\`). Default \`2\`.

- zoom:

  Logical; passed straight to \[dp_map_societies()\]. If \`TRUE\` (the
  default), the map is cropped to a padded bounding box around the
  plotted societies rather than always showing the whole world – so a
  selection of societies all in, say, Madagascar produces a map of
  Madagascar rather than a world map with a tiny cluster of points. Set
  to \`FALSE\` to always show the whole world.

## Value

A \`ggplot\` object; print it to display, or add further \`ggplot2\`
layers/theming to customize it (e.g. a different colour scale via \`+
ggplot2::scale_colour_manual(...)\`).

## Examples

``` r
if (FALSE) { # \dontrun{
plot_variable_map(dp_societies(region = "Southern Africa")$soc_id, "B035")
plot_variable_map(
  dp_societies(region = "Southern Africa")$soc_id, "B035", label = TRUE
)
} # }
```
