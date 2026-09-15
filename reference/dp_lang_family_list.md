# List every language family represented among coded societies

A quick way to see what's available before filtering
\[dp_societies()\]/\[get_society()\]'s
\`lang_family\`/\`lang_family_id\` – equivalent to
\`sort(unique(dp_societies()\$lang_family))\`, but without building the
full society table yourself. Only considers \`type = "society"\` rows
(societies with coded cultural data) – see \[dp_societies()\]'s \`type\`
argument.

## Usage

``` r
dp_lang_family_list()
```

## Value

A sorted character vector of every distinct top-level language family
name (see \[dplace_societies\]'s \`lang_family\`/\`lang_family_id\`
columns for how families are derived, including the note on isolates
being their own top-level family).

## Examples

``` r
dp_lang_family_list()
#>   [1] "Abkhaz-Adyge"             "Afro-Asiatic"            
#>   [3] "Ainu"                     "Algic"                   
#>   [5] "Alsea-Yaquina"            "Anim"                    
#>   [7] "Araucanian"               "Arawakan"                
#>   [9] "Athabaskan-Eyak-Tlingit"  "Atlantic-Congo"          
#>  [11] "Austroasiatic"            "Austronesian"            
#>  [13] "Aymaran"                  "Barbacoan"               
#>  [15] "Basque"                   "Blue Nile Mao"           
#>  [17] "Bookkeeping"              "Border"                  
#>  [19] "Bororoan"                 "Burushaski"              
#>  [21] "Caddoan"                  "Cariban"                 
#>  [23] "Central Sudanic"          "Chibchan"                
#>  [25] "Chicham"                  "Chimakuan"               
#>  [27] "Chimariko"                "Chinookan"               
#>  [29] "Chiquitano"               "Chitimacha"              
#>  [31] "Chocoan"                  "Chonan"                  
#>  [33] "Chono"                    "Chukotko-Kamchatkan"     
#>  [35] "Chumashan"                "Coahuilteco"             
#>  [37] "Cochimi-Yuman"            "Coosan"                  
#>  [39] "Dizoid"                   "Dogon"                   
#>  [41] "Dravidian"                "East Kutubu"             
#>  [43] "Eastern Jebel"            "Eastern Trans-Fly"       
#>  [45] "Eleman"                   "Eskimo-Aleut"            
#>  [47] "Furan"                    "Fuyug"                   
#>  [49] "Gaagudju"                 "Great Andamanese"        
#>  [51] "Greater Kwerba"           "Guahiboan"               
#>  [53] "Guaicurian"               "Guaicuruan"              
#>  [55] "Guató"                    "Gunwinyguan"             
#>  [57] "Hadza"                    "Haida"                   
#>  [59] "Heibanic"                 "Hmong-Mien"              
#>  [61] "Huavean"                  "Huitotoan"               
#>  [63] "Ijoid"                    "Indo-European"           
#>  [65] "Iroquoian"                "Iwaidjan Proper"         
#>  [67] "Japonic"                  "Jarawa-Onge"             
#>  [69] "Jarrakan"                 "Jicaquean"               
#>  [71] "Kadugli-Krongo"           "Kakua-Nukak"             
#>  [73] "Karankawa"                "Kartvelian"              
#>  [75] "Karuk"                    "Katukinan"               
#>  [77] "Kawesqar"                 "Keresan"                 
#>  [79] "Khoe-Kwadi"               "Kiowa-Tanoan"            
#>  [81] "Kiwaian"                  "Klamath-Modoc"           
#>  [83] "Koiarian"                 "Kolopom"                 
#>  [85] "Koman"                    "Koreanic"                
#>  [87] "Kru"                      "Kunama"                  
#>  [89] "Kutenai"                  "Kxa"                     
#>  [91] "Laragia"                  "Lencan"                  
#>  [93] "Lengua-Mascoy"            "Maban"                   
#>  [95] "Maiduan"                  "Mailuan"                 
#>  [97] "Mande"                    "Maningrida"              
#>  [99] "Mataguayan"               "Mayan"                   
#> [101] "Misumalpan"               "Miwok-Costanoan"         
#> [103] "Mixe-Zoque"               "Mongolic-Khitan"         
#> [105] "Muskogean"                "Máku"                    
#> [107] "Nakh-Daghestanian"        "Nambiquaran"             
#> [109] "Nara"                     "Narrow Talodi"           
#> [111] "Natchez"                  "Ndu"                     
#> [113] "Nilotic"                  "Nivkh"                   
#> [115] "North Halmahera"          "Northern Daly"           
#> [117] "Nubian"                   "Nuclear Torricelli"      
#> [119] "Nuclear Trans New Guinea" "Nuclear-Macro-Je"        
#> [121] "Nyimang"                  "Nyulnyulan"              
#> [123] "Otomanguean"              "Palaihnihan"             
#> [125] "Pama-Nyungan"             "Pano-Tacanan"            
#> [127] "Peba-Yagua"               "Pomoan"                  
#> [129] "Pumé"                     "Purari"                  
#> [131] "Páez"                     "Quechuan"                
#> [133] "Ramu"                     "Sahaptian"               
#> [135] "Saharan"                  "Saliban"                 
#> [137] "Salinan"                  "Salishan"                
#> [139] "Sandawe"                  "Sepik"                   
#> [141] "Seri"                     "Shastan"                 
#> [143] "Shom Peng"                "Sino-Tibetan"            
#> [145] "Siouan"                   "Siuslaw"                 
#> [147] "Sko"                      "Songhay"                 
#> [149] "South Bougainville"       "South Omotic"            
#> [151] "South-Eastern Tasmanian"  "Southern Daly"           
#> [153] "Sumerian"                 "Surmic"                  
#> [155] "Ta-Ne-Omotic"             "Tai-Kadai"               
#> [157] "Takelma"                  "Tamaic"                  
#> [159] "Tangkic"                  "Tarascan"                
#> [161] "Tequistlatecan"           "Ticuna-Yuri"             
#> [163] "Timor-Alor-Pantar"        "Timucua"                 
#> [165] "Tiwi"                     "Totonacan"               
#> [167] "Trumai"                   "Tsimshian"               
#> [169] "Tucanoan"                 "Tungusic"                
#> [171] "Tupian"                   "Turkic"                  
#> [173] "Tuu"                      "Unclassifiable"          
#> [175] "Uralic"                   "Uru-Chipaya"             
#> [177] "Uto-Aztecan"              "Wadjiginy"               
#> [179] "Wakashan"                 "Waorani"                 
#> [181] "Warao"                    "Washo"                   
#> [183] "Western Tasmanian"        "Wintuan"                 
#> [185] "Worrorran"                "Yam"                     
#> [187] "Yana"                     "Yanomamic"               
#> [189] "Yele"                     "Yeniseian"               
#> [191] "Yokutsan"                 "Yuchi"                   
#> [193] "Yukaghir"                 "Yuki-Wappo"              
#> [195] "Yámana"                   "Zamucoan"                
#> [197] "Zuni"                    
```
