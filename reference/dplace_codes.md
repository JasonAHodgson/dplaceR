# Codes for categorical/ordinal D-PLACE variables

One row per possible code (category) for a categorical or ordinal
variable in \[dplace_variables\].

## Usage

``` r
dplace_codes
```

## Format

A tibble with one row per code and the following columns:

- code_id:

  Character. Identifier used in \[dplace_values\]\$code_id.

- var_id:

  Character. The variable this code belongs to; joins to
  \[dplace_variables\].

- name:

  Character. Short label for this code.

- description:

  Character. Longer description.

- ord:

  Integer. Rank order, for ordinal variables.

## Source

D-PLACE CLDF dataset, <https://github.com/D-PLACE/dplace-cldf>. See
\[dplace_meta\] for the exact release bundled with this package.

## See also

\[dp_codes()\]
