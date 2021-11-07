# NowCastingGDP
Research project for nowcasting GDP for South Africa

## Some notes on the folder structures

1. **research** is for work in progress
2. **data** is for all different forms of data
3. **figures** is for figures generated from the code 
4. **papers** includes literature, organised by methodology
5. **scripts** is for scripts that are supplemental to source code
6. **src** is for the source code

# R Projects

When working on code please open from R Project at root folder structure
to preserve relative file paths.


## Google Trends Data

In data/google_trends/ there is a keywords file. One can add any keywords of
interest to this file.

The "scripts/download_and_save_google_trends_data.R" processes the keywords list
and saves the data back to "data/google_trends/" using keywords with the current
date as a suffix.



