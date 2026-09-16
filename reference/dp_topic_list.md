# List every topic used in D-PLACE's variable categories

A quick way to see what's available before filtering by
\[dp_topics()\]/\[dp_variables()\]'s \`topic\`/\`category\` – equivalent
to \`sort(unique(dp_topics()\$topic))\`, but without building the full
variable/topic table yourself.

## Usage

``` r
dp_topic_list(type = NULL)
```

## Arguments

- type:

  Optional character vector restricting to variable type(s):
  \`"Categorical"\`, \`"Ordinal"\`, and/or \`"Continuous"\`. Passed
  straight to \[dp_topics()\] – see there for what it means to filter
  topics by type.

## Value

A sorted character vector of every distinct topic (see \[dp_topics()\]
for how topics are derived, including its note on near-duplicate
spellings that aren't merged here either).

## Examples

``` r
dp_topic_list()
#>  [1] "Anthropometry"                         
#>  [2] "Architecture"                          
#>  [3] "Ceramics and Art"                      
#>  [4] "Ceremony"                              
#>  [5] "Childhood"                             
#>  [6] "Class"                                 
#>  [7] "Climate"                               
#>  [8] "Clothing"                              
#>  [9] "Community"                             
#> [10] "Community organization"                
#> [11] "Data Quality"                          
#> [12] "Death"                                 
#> [13] "Demography"                            
#> [14] "Dwelling"                              
#> [15] "Dwellings"                             
#> [16] "Ecology"                               
#> [17] "Economics"                             
#> [18] "Economy"                               
#> [19] "Games"                                 
#> [20] "Gender"                                
#> [21] "Gossip"                                
#> [22] "Health"                                
#> [23] "Household"                             
#> [24] "Housing"                               
#> [25] "Infancy"                               
#> [26] "Kinship"                               
#> [27] "Labor"                                 
#> [28] "Labour"                                
#> [29] "Law and Judicial Process"              
#> [30] "Leadership"                            
#> [31] "Life cycle"                            
#> [32] "Marriage"                              
#> [33] "Material culture"                      
#> [34] "Metalworking"                          
#> [35] "Modernization"                         
#> [36] "Mourning"                              
#> [37] "Physical Landscape"                    
#> [38] "Political Organization"                
#> [39] "Politics"                              
#> [40] "Population"                            
#> [41] "Property"                              
#> [42] "Religion"                              
#> [43] "Ritual"                                
#> [44] "Settlement"                            
#> [45] "Settlements"                           
#> [46] "Sexual practices"                      
#> [47] "Social Organization and Stratification"
#> [48] "Special Knowledge and Practices"       
#> [49] "Subsistence"                           
#> [50] "Technology"                            
#> [51] "Tools and Utensils and Textiles"       
#> [52] "War"                                   
#> [53] "Warfare"                               
#> [54] "Watercraft and Navigation"             
#> [55] "Wealth Transactions"                   
#> [56] "Wealth transactions"                   
dp_topic_list(type = "Continuous")
#>  [1] "Anthropometry"          "Childhood"              "Climate"               
#>  [4] "Community organization" "Data Quality"           "Death"                 
#>  [7] "Demography"             "Ecology"                "Economy"               
#> [10] "Gender"                 "Kinship"                "Life cycle"            
#> [13] "Marriage"               "Mourning"               "Physical Landscape"    
#> [16] "Politics"               "Population"             "Property"              
#> [19] "Religion"               "Ritual"                 "Settlement"            
#> [22] "Subsistence"            "Warfare"               
```
