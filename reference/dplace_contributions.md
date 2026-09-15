# D-PLACE dataset contributions (sources)

One row per source dataset or phylogeny contributed to D-PLACE (e.g. the
Binford hunter-gatherer dataset, the Ethnographic Atlas).

## Usage

``` r
dplace_contributions
```

## Format

A tibble with the following columns:

- contribution_id:

  Character. Joins to \`contribution_id\` in \[dplace_societies\],
  \[dplace_variables\], and \[dplace_trees\].

- name:

  Character. Dataset name.

- description:

  Character. Description of the dataset.

- contributor:

  Character. Who contributed/compiled it.

- citation:

  Character. Suggested citation.

- doi:

  Character. DOI, where available.

- type:

  Character. e.g. \`"dataset"\` or \`"phylogeny"\`.

## Source

D-PLACE CLDF dataset, <https://github.com/D-PLACE/dplace-cldf>. See
\[dplace_meta\] for the exact release bundled with this package.

## See also

\[dp_contributions()\]
