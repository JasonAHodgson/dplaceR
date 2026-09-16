# Package index

## Societies

Browse, search, and filter D-PLACE societies, including cross-dataset
links, country lookup, and language-family classification.

- [`dp_societies()`](https://jasonahodgson.github.io/dplaceR/reference/dp_societies.md)
  : Browse or filter D-PLACE societies
- [`get_society()`](https://jasonahodgson.github.io/dplaceR/reference/get_society.md)
  : Search for societies matching metadata criteria
- [`contains()`](https://jasonahodgson.github.io/dplaceR/reference/contains.md)
  : Partial or regex matching for society search functions
- [`get_related_societies()`](https://jasonahodgson.github.io/dplaceR/reference/get_related_societies.md)
  : Find other societies coded from the same real-world group
- [`get_society_country()`](https://jasonahodgson.github.io/dplaceR/reference/get_society_country.md)
  : Look up a society's country from its coordinates
- [`get_society_meta()`](https://jasonahodgson.github.io/dplaceR/reference/get_society_meta.md)
  : Append D-PLACE society metadata to a tibble
- [`dp_map_societies()`](https://jasonahodgson.github.io/dplaceR/reference/dp_map_societies.md)
  : Plot societies on a world map
- [`dp_lang_family_list()`](https://jasonahodgson.github.io/dplaceR/reference/dp_lang_family_list.md)
  : List every language family represented among coded societies
- [`dp_lang_family_table()`](https://jasonahodgson.github.io/dplaceR/reference/dp_lang_family_table.md)
  : Count how many coded societies belong to each language family
- [`get_lang_clade()`](https://jasonahodgson.github.io/dplaceR/reference/get_lang_clade.md)
  : Get societies belonging to a language clade (e.g. Bantu)

## Cultural and environmental variables

Browse and search the cultural/environmental variables that can be coded
for a society, and the topics/categories they belong to.

- [`dp_variables()`](https://jasonahodgson.github.io/dplaceR/reference/dp_variables.md)
  : Browse or filter D-PLACE cultural variables
- [`dp_search_variables()`](https://jasonahodgson.github.io/dplaceR/reference/dp_search_variables.md)
  : Search D-PLACE variables by keyword
- [`dp_codes()`](https://jasonahodgson.github.io/dplaceR/reference/dp_codes.md)
  : Look up codes for categorical/ordinal D-PLACE variables
- [`dp_topics()`](https://jasonahodgson.github.io/dplaceR/reference/dp_topics.md)
  : Browse D-PLACE variables by atomic topic
- [`dp_topic_list()`](https://jasonahodgson.github.io/dplaceR/reference/dp_topic_list.md)
  : List every topic used in D-PLACE's variable categories
- [`dp_topic_table()`](https://jasonahodgson.github.io/dplaceR/reference/dp_topic_table.md)
  : Count how many variables carry each topic

## Coded values and analysis-ready tables

Retrieve the coded values linking societies to variables, and assemble
them into long- or wide-format tables ready for analysis.

- [`dp_values()`](https://jasonahodgson.github.io/dplaceR/reference/dp_values.md)
  : Look up raw coded values
- [`dp_variable_data()`](https://jasonahodgson.github.io/dplaceR/reference/dp_variable_data.md)
  : Build an analysis-ready table for one or more variables
- [`get_society_data()`](https://jasonahodgson.github.io/dplaceR/reference/get_society_data.md)
  : Search and assemble a table of societies' cultural measurements

## Distance measures

Compute geographic, cultural, and linguistic distance between societies,
either pairwise or from a single reference point.

- [`get_geo_distance()`](https://jasonahodgson.github.io/dplaceR/reference/get_geo_distance.md)
  : Geographic distance from a point or society to a list of societies
- [`get_pairwise_geo_distance()`](https://jasonahodgson.github.io/dplaceR/reference/get_pairwise_geo_distance.md)
  : Pairwise geographic distance between societies
- [`get_cult_distance()`](https://jasonahodgson.github.io/dplaceR/reference/get_cult_distance.md)
  : Cultural distance from a specified culture to a list of societies
- [`get_pairwise_cult_distance()`](https://jasonahodgson.github.io/dplaceR/reference/get_pairwise_cult_distance.md)
  : Pairwise cultural distance between societies
- [`get_language_distance()`](https://jasonahodgson.github.io/dplaceR/reference/get_language_distance.md)
  : Language (branch-length) distance from a point or society to a list
  of societies
- [`get_pairwise_language_distance()`](https://jasonahodgson.github.io/dplaceR/reference/get_pairwise_language_distance.md)
  : Pairwise language (branch-length) distance between societies

## Group differentiation (Fst/Qst)

Measure cultural differentiation between GROUPS of societies (e.g. by
region or language family), analogous to population-genetic Fst/Qst.

- [`get_cultural_FST()`](https://jasonahodgson.github.io/dplaceR/reference/get_cultural_FST.md)
  : Cultural differentiation (Fst-style) between groups of societies
- [`get_pairwise_cultural_FST()`](https://jasonahodgson.github.io/dplaceR/reference/get_pairwise_cultural_FST.md)
  : Pairwise cultural differentiation (Fst-style) between groups of
  societies

## Language phylogenies

Browse and parse the language phylogenies/classification trees bundled
with D-PLACE.

- [`dp_trees()`](https://jasonahodgson.github.io/dplaceR/reference/dp_trees.md)
  : Browse D-PLACE language phylogenies
- [`dp_tree()`](https://jasonahodgson.github.io/dplaceR/reference/dp_tree.md)
  : Load a D-PLACE language phylogeny

## Dataset contributions

The source datasets and phylogenies contributed to D-PLACE.

- [`dp_contributions()`](https://jasonahodgson.github.io/dplaceR/reference/dp_contributions.md)
  : Browse D-PLACE dataset contributions (sources)

## Bundled data

The tidy tables bundled with dplaceR, snapshotting a specific D-PLACE
(and Glottolog) release. Most users will access these through the
functions above rather than directly.

- [`dplace_societies`](https://jasonahodgson.github.io/dplaceR/reference/dplace_societies.md)
  : Societies in D-PLACE
- [`dplace_variables`](https://jasonahodgson.github.io/dplaceR/reference/dplace_variables.md)
  : Cultural and environmental variables in D-PLACE
- [`dplace_codes`](https://jasonahodgson.github.io/dplaceR/reference/dplace_codes.md)
  : Codes for categorical/ordinal D-PLACE variables
- [`dplace_values`](https://jasonahodgson.github.io/dplaceR/reference/dplace_values.md)
  : Coded values linking societies to variables
- [`dplace_contributions`](https://jasonahodgson.github.io/dplaceR/reference/dplace_contributions.md)
  : D-PLACE dataset contributions (sources)
- [`dplace_trees`](https://jasonahodgson.github.io/dplaceR/reference/dplace_trees.md)
  : Language phylogenies in D-PLACE
- [`dplace_meta`](https://jasonahodgson.github.io/dplaceR/reference/dplace_meta.md)
  : Metadata about the bundled D-PLACE snapshot

## About this package

- [`dplaceR`](https://jasonahodgson.github.io/dplaceR/reference/dplaceR-package.md)
  [`dplaceR-package`](https://jasonahodgson.github.io/dplaceR/reference/dplaceR-package.md)
  : dplaceR: An R Interface to the D-PLACE Cross-Cultural Database
- [`dp_citation()`](https://jasonahodgson.github.io/dplaceR/reference/dp_citation.md)
  : How to cite dplaceR, D-PLACE, and the bundled data snapshot
