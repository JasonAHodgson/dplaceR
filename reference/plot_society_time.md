# Plot societies through time, one point per society

Plots each society along the x axis at its D-PLACE \`main_focal_year\` –
the (ethnographic) year the society's coded data mainly reflects (see
\[dplace_societies\]). Points are jittered vertically by default (the y
axis carries no meaning either way) purely so societies sharing a focal
year don't sit exactly on top of each other. Optionally coloured by any
column in \`data\`, e.g. \`region\` or \`lang_family\`, or – via the
variable-aware \[plot_variable_time()\] – a D-PLACE variable's coded
value.

## Usage

``` r
plot_society_time(
  data,
  color = NULL,
  jitter = TRUE,
  jitter_seed = 42,
  label = FALSE,
  point_size = 2
)
```

## Arguments

- data:

  Either a character vector of D-PLACE society IDs, or a data
  frame/tibble. If it doesn't already have a \`main_focal_year\` column,
  it must have a \`soc_id\` column, which is used to look it up via
  \[get_society_meta()\]. Rows with an unknown focal year are dropped
  with a warning.

- color:

  Optional; the name of a column in \`data\` to map to point colour
  (e.g. \`"region"\`, \`"lang_family"\`, or a variable's value). Left
  plain (a single colour) if omitted.

- jitter:

  Logical; if \`TRUE\` (the default), points are jittered vertically so
  societies sharing a focal year remain distinguishable. Set \`FALSE\`
  to plot them exactly on the axis line instead.

- jitter_seed:

  A random seed used only for the vertical jitter, so repeated calls on
  the same data produce the same layout. Default \`42\`; change it for a
  different (but still reproducible) layout.

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
plot_society_time(c("B72", "B73", "B79"))
plot_society_time(dp_societies(region = "Southern Africa"), color = "lang_family")
} # }
```
