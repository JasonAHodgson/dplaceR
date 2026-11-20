# Plot a coded variable through time, one point per society

The time-axis counterpart to \[plot_variable_map()\]: given a chosen
subset of societies and a single D-PLACE variable, plots each society at
its main focal year (see \[plot_society_time()\]), coloured by its coded
value for that variable – e.g. community marriage organization
(\`"B035"\`) across a set of societies, to see whether/how it varies
over the period the sample spans. Handles the same D-PLACE-specific
details as \[plot_variable_map()\]: a society's more than one recorded
observation is collapsed to one, D-PLACE's missing-data sentinel code
doesn't count as a real observation (including in an \`"Ordinal"\`
variable's colour-scale levels), and an \`"Ordinal"\` variable's colour
scale is ordered by the codes' rank (\`ord\`) rather than
alphabetically.

## Usage

``` r
plot_variable_time(
  soc_id,
  var_id,
  drop_na = TRUE,
  jitter = TRUE,
  jitter_seed = 42,
  label = FALSE,
  point_size = 2
)
```

## Arguments

- soc_id:

  Character vector of D-PLACE society IDs to plot. Also accepts a data
  frame/tibble with a \`soc_id\` column, from which the column is used
  automatically.

- var_id:

  A single D-PLACE variable ID (see \[dp_variables()\] or
  \[dp_search_variables()\] to find one) – one plot, one variable; call
  this again for another.

- drop_na:

  Logical; societies in \`soc_id\` with no usable coded value for
  \`var_id\` (either genuinely uncoded, or only carrying D-PLACE's
  missing-data sentinel) are always identified, with a warning naming
  how many. If \`TRUE\` (the default), they're then dropped from the
  plot entirely; if \`FALSE\`, they're kept and shown as \`NA\` (grey,
  by ggplot2's default).

- jitter, jitter_seed:

  Passed straight to \[plot_society_time()\]; control the vertical
  jitter that keeps societies sharing a focal year distinguishable.
  Defaults \`TRUE\`/\`42\`.

- label:

  Logical; if \`TRUE\`, label each point with its \`soc_id\`. Passed
  straight to \[plot_society_time()\]. Default \`FALSE\`.

- point_size:

  Point size, passed to \[plot_society_time()\] (and on to
  \`ggplot2::geom_point()\`). Default \`2\`.

## Value

A \`ggplot\` object; print it to display, or add further \`ggplot2\`
layers/theming to customize it (e.g. a different colour scale via \`+
ggplot2::scale_colour_manual(...)\`).

## Examples

``` r
if (FALSE) { # \dontrun{
plot_variable_time(dp_societies(region = "Southern Africa")$soc_id, "B035")
plot_variable_time(
  dp_societies(region = "Southern Africa")$soc_id, "B035", label = TRUE
)
} # }
```
