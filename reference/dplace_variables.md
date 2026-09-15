# Cultural and environmental variables in D-PLACE

One row per variable that can be coded for a society (e.g. subsistence
strategy, descent system, settlement pattern).

## Usage

``` r
dplace_variables
```

## Format

A tibble with one row per variable and the following columns:

- var_id:

  Character. D-PLACE variable identifier, e.g. \`"EA202"\`. Used to join
  to \[dplace_values\] and \[dplace_codes\].

- name:

  Character. Short variable name.

- description:

  Character. Longer description of what the variable measures.

- category:

  Character. Broad topic, e.g. \`"Subsistence"\`, \`"Kinship"\`,
  \`"Warfare"\`.

- type:

  Character. \`"Categorical"\`, \`"Ordinal"\`, or \`"Continuous"\`.

- unit:

  Character. Unit of measurement, for continuous variables.

- contribution_id:

  Character. Identifies the source dataset; joins to
  \[dplace_contributions\].

## Source

D-PLACE CLDF dataset, <https://github.com/D-PLACE/dplace-cldf>. See
\[dplace_meta\] for the exact release bundled with this package.

## See also

\[dp_variables()\], \[dp_search_variables()\]
