# Coded values linking societies to variables

The core "long format" data table of D-PLACE: one row per
society/variable measurement.

## Usage

``` r
dplace_values
```

## Format

A tibble with the following columns:

- id:

  Character. Unique row identifier.

- soc_id:

  Character. Society identifier; joins to \[dplace_societies\].

- var_id:

  Character. Variable identifier; joins to \[dplace_variables\].

- value:

  Character. The raw coded value: for categorical/ordinal variables this
  is a code, for continuous variables a number stored as text.

- code_id:

  Character. For categorical/ordinal variables, joins to
  \[dplace_codes\]; \`NA\` for continuous variables.

- year:

  Integer. Year associated with this observation, where given.

- source:

  Character. Semicolon-separated citation key(s) for the original
  source(s) of this observation.

- admin_comment:

  Character. Curatorial comment, where present.

## Source

D-PLACE CLDF dataset, <https://github.com/D-PLACE/dplace-cldf>. See
\[dplace_meta\] for the exact release bundled with this package.

## See also

\[dp_values()\], \[dp_variable_data()\]
