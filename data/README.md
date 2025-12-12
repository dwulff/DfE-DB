# About Studies

## Introduction

In this data folder, every paper has its own sub-folder. The sub-folders were named by the initials of all authors and the year of publication. </br>
</br>
In every paper folder, there are two sub-folders, one R script, and one README.md. 
In the "raw" folder, we have the raw data from the authors. If the "raw" folder is empty, it means that the author refused to share their raw data publicly. You can look into the README.md to either contact us or use information we provided to contact the author for raw data. 
In the "processed" folder, there are the standard-form data we produced from the raw data. In this folder, every study has one data table and one option table. They are named by "abbreviation of paper_study_data/option.csv". 
With the R script, you can transform the raw data into our processed data.
In README, you can find the title, authors, abstract, the download link of the paper, the issues we met when processing the raw data, and whether you need to contact us or the authors for the raw data if applicable.

## Information Table
Here is some basic information about the studies in our database. It includes the paradigm this study used, the number of participants, the number of problems, etc. With this table, you can get a basic understanding of what kinds of studies are included in our database and how much data you can get by using our database. You can also find these information in 'feature_table.csv'.</br>

### Table
| study | paradigm | n_participants | n_problems | n_problems_per_participant | problems_differ | n_trials | trials_differ | n_options_per_problem | n_outcomes_per_option | stationarity | feedback_formate | numerical_feedback | feedback_type | problem_type | problem_domain | problem_stage | n_conditions | design | study_context | decisions_from_description | incentivization | identical_outcome | sampling |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |--------------------| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DBDF2016_1 | 2 step dynamic probability learning | 171 | 2 | 2 | no | 148 | no | 2 | 2 | dynamic | partial | graphical          | event | risky_risky | gain | multi-stage | 3 | within | Behavioral;Genetics | no | no | yes | 0 |
| KCG2016_1 | 2 step dynamic probability learning | 199 | 1 | 1 | no | 120 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | multi-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| KCG2016_2 | 2 step dynamic probability learning | 207 | 1 | 1 | no | 60 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | multi-stage | 2 | within | Behavioral | no | yes | yes | 0 |
| AK2011_1 | binary prediction | 44 | 1 | 1 | no | 100 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| BE1998_1 | binary prediction | 42 | 3 | 1 | no | 500 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | variable | single-stage | 3 | between | Behavioral | no | yes | yes | 0 |
| GN2015_1 | binary prediction | 14 | 6 | 6 | no | 6 | yes | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| GS2008_1 | binary prediction | 80 | 1 | 1 | no | 288 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | within | Behavioral | no | yes | yes | 0 |
| GS2008_2 | binary prediction | 139 | 1 | 1 | no | 288 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | within | Behavioral | no | yes | yes | 0 |
| LDP2011_1 | binary prediction | 20 | 1 | 1 | no | 80 | no | 2 | 2 | stationary | full | numerical          | outcome | variable | mixed | single-stage | 2 | within | MRI | no | no | yes | 0 |
| NKJR2013_2 | binary prediction | 100 | 1 | 1 | no | 300 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 4 | between | Behavioral | no | yes | yes | 0 |
| OTM2011_1 | binary prediction | 160 | 1 | 1 | no | 310 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| SKH2014_1 | binary prediction | 18 | 1 | 1 | no | 147 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | yes | 0 |
| SKH2014_2 | binary prediction | 16 | 1 | 1 | no | 235 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 1 | within | fMRI | no | no | yes | 0 |
| BE2003_1 | continuous bandits | 36 | 3 | 1 | no | 200 | no | 2 | continuous | stationary | partial | numerical          | outcome | risky_risky | variable | single-stage | 3 | between | Behavioral | no | yes | no | 0 |
| CGDW2014_1 | continuous bandits | 75 | 1 | 1 | no | 150 | no | 2 | continuous | stationary | partial | graphical          | outcome | risky_risky | gain | single-stage | 3 | between | Behavioral;Clinical | no | no | no | 0 |
| EEY2008_3 | continuous bandits | 100 | 8 | 4 | no | 100 | no | 2 | continuous | stationary | partial | numerical          | outcome | risky_risky | variable | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| WM2014_2 | continuous bandits | 23 | 1 | 1 | no | 250 | no | 2 | continuous | stationary | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | no | 0 |
| YB2008_1 | continuous bandits | 90 | 3 | 3 | no | 200 | no | 2 | continuous | stationary | partial | numerical          | outcome | variable | mixed | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| YB2008_2 | continuous bandits | 90 | 3 | 3 | no | 200 | no | 2 | continuous | stationary | partial | numerical          | outcome | variable | mixed | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| YE2007_2 | continuous bandits | 24 | 4 | 4 | no | 100 | no | 3 | continuous | stationary | partial | numerical          | outcome | risky_risky | variable | single-stage | 2 | within | Behavioral | no | yes | no | 0 |
| JBB2008_1 | description bandits | 29 | 2 | 2 | no | 119 | no | 2 | 2 | stationary | partial;none | numerical          | outcome | risky_safe | gain | single-stage | 2 | between | Behavioral | yes | yes | no | 0 |
| JBB2010_1 | description bandits | 20 | 4 | 4 | no | 60 | no | 2 | 2 | stationary | partial;none | numerical          | outcome | risky_safe | gain | single-stage | 2 | within | fMRI | yes | yes | no | 0 |
| TAE2013_1 | description bandits | 30 | 4 | 4 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | mixed | single-stage | 2 | within | Behavioral | yes | yes | no | 0 |
| YB2006_1 | description bandits | 80 | 2 | 1 | no | 400 | no | 2 | 2 | stationary | both | numerical          | outcome | risky_risky | loss | single-stage | 2 | between | Behavioral | yes | yes | no | 0 |
| YBE2005_1 | description bandits | 24 | 1 | 1 | no | 100 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_risky | loss | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| YDE2008_1 | description bandits | 100 | 2 | 1 | no | 400 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | loss | single-stage | 2 | between | Behavioral | yes | yes | no | 0 |
| YDE2008_2 | description bandits | 32 | 1 | 1 | no | 400 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | loss | single-stage | 2 | between | Behavioral | yes | yes | no | 0 |
| BEE2009_1 | dynamic bandits | 54 | 2 | 1 | no | 300 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_safe | mixed | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| BEE2009_2 | dynamic bandits | 40 | 20 | 10 | no | 100 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| BWGN2013_1 | dynamic bandits | 95 | 2 | 2 | no | 80 | no | 4 | 10 | dynamic | partial | numerical          | outcome | risky_risky | variable | single-stage | 2 | between | Behavioral;Clinical | no | no | no | 0 |
| HE2013_1 | dynamic bandits | 24 | 4 | 2 | no | 100 | no | 2 | 2 | dynamic | full | numerical          | outcome | variable | gain | single-stage | 4 | between | Behavioral | no | yes | no | 0 |
| HE2013_2 | dynamic bandits | 49 | 8 | 2 | no | 100 | no | 2 | 2 | dynamic | full | numerical          | outcome | variable | gain | single-stage | 4 | between | Behavioral | no | yes | no | 0 |
| ICRS2015_1 | dynamic bandits | 28 | 1 | 1 | no | 1892 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| ICRS2015_2 | dynamic bandits | 26 | 1 | 1 | no | 1936 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | EEG | no | yes | yes | 0 |
| KOSL2012_1 | dynamic bandits | 139 | 3 | 1 | no | 500 | no | 2 | continuous | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 3 | between | Behavioral | no | yes | no | 0 |
| LLG2014_1 | dynamic bandits | 80 | 6 | 6 | no | 100 | no | 2 | 2 | dynamic | full | numerical          | outcome | risky_risky | mixed | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| OKML2014_1 | dynamic bandits | 43 | 1 | 1 | no | 200 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Psychophysiological | no | yes | no | 0 |
| OKML2014_2 | dynamic bandits | 32 | 2 | 2 | no | 100 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Psychophysiological | no | yes | no | 0 |
| RM2009_1 | dynamic bandits | 40 | 4 | 4 | no | 100 | no | 2 | 2 | dynamic | full | numerical          | outcome | risky_risky | mixed | single-stage | 2 | between | Behavioral | no | no | yes | 0 |
| RM2009_2 | dynamic bandits | 52 | 6 | 6 | no | 60 | no | 2 | 2 | dynamic | full | numerical          | outcome | risky_risky | mixed | single-stage | 2 | between | Behavioral | no | yes | variable | 0 |
| SK2015_1 | dynamic bandits | 80 | 4 | 1 | no | 200 | no | 4 | continuous | dynamic | partial | numerical          | outcome | risky_risky | mixed | single-stage | 4 | between | Behavioral | no | no | no | 0 |
| ST2009_1 | dynamic bandits | 21 | 1 | 1 | no | 988 | yes | 2 | 1 | dynamic | partial | numerical          | outcome | safe_safe | gain | single-stage | 1 | within | Behavioral | no | no | no | 0 |
| WM2012_1 | dynamic bandits | 114 | 2 | 1 | no | 80 | no | 4 | 10 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 2 | between | Behavioral | no | no | no | 0 |
| WM2014_3 | dynamic bandits | 23 | 1 | 1 | no | 250 | no | 2 | continuous | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | no | 0 |
| WMM2008_1 | dynamic bandits | 30 | 3 | 1 | no | 79 | no | 2 | 10 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 3 | between | Behavioral | no | yes | no | 0 |
| WMM2008_2 | dynamic bandits | 30 | 3 | 1 | no | 79 | no | 2 | 10 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 3 | between | Behavioral | no | yes | yes | 0 |
| CDFO2012_1 | dynamic probability learning | 16 | 10 | 10 | no | 33 | yes | 2 | 2 | dynamic | partial | graphical;food     | event | risky_risky | gain | single-stage | 10 | within | MRI | no | yes | yes | 0 |
| DSCA2015_1 | dynamic probability learning | 47 | 1 | 1 | no | 294 | no | 2 | 2 | dynamic | partial | graphical          | event | risky_risky | gain | single-stage | 1 | within | MRI;Clinical | no | no | yes | 0 |
| LLLH2014_1 | dynamic probability learning | 69 | 2 | 1 | no | 480 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 2 | between | Behavioral;Clinical | no | yes | yes | 0 |
| PLKB2017_1 | dynamic probability learning | 20 | 1 | 1 | no | 192 | no | 2 | 2 | dynamic | partial | numerical          | event | risky_risky | mixed | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| PLKB2017_2 | dynamic probability learning | 20 | 1 | 1 | no | 192 | no | 2 | 2 | dynamic | full | numerical          | event | risky_risky | mixed | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| SNJG2013_1 | dynamic probability learning | 12 | 1 | 1 | no | 800 | no | 2 | 2 | dynamic | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| WRO2009_1 | dynamic probability learning | 23 | 1 | 1 | no | 298 | no | 2 | 2 | dynamic | partial | graphical          | outcome | risky_risky | gain | single-stage | 1 | within | MRI | no | no | yes | 0 |
| CN2009a_1 | free sampling | 80 | 8 | 8 | no | 27 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 4 | within | Behavioral | no | yes | no | 1 |
| CN2009b_1 | free sampling | 40 | 10 | 10 | no | 12 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 2 | within | Behavioral | yes | yes | no | 1 |
| CN2011b_1 | free sampling | 40 | 4 | 4 | no | 100 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| FAOV2014_1 | free sampling | 89 | 12 | 12 | no | 34 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| FHR2014_1 | free sampling | 49 | 4 | 4 | no | 19 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| FHR2014_2 | free sampling | 112 | 9 | 9 | no | 42 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 4 | between | Behavioral | no | yes | no | 1 |
| FMH2015_1 | free sampling | 121 | 12 | 12 | no | 29 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| FMH2015_2 | free sampling | 70 | 84 | 84 | no | 27 | yes | 2 | 3 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| GFHA2012_1 | free sampling | 22 | 59 | 59 | no | 33 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_risky | gain | single-stage | 4 | between | Behavioral | no | yes | no | 1 |
| GHHF2016_1 | free sampling | 26 | 60 | 60 | no | 35 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| GHHF2016_2 | free sampling | 51 | 60 | 60 | no | 43 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| GHHF2016_3 | free sampling | 37 | 130 | 65 | no | 51 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| GM2016_1 | free sampling | 125 | 2 | 1 | no | 7 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| GM2016_2 | free sampling | 800 | 4 | 1 | no | 52 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 8 | between | Behavioral | no | yes | no | 1 |
| HBWE2004_1 | free sampling | 50 | 6 | 3 | no | 21 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| HNG2013_1 | free sampling | 64 | 5 | 5 | no | 22 | yes | 32 | 2 | stationary | partial | numerical          | outcome | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| HP2010_1 | free sampling | 88 | 12 | 12 | no | 15 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| HPH2008_1 | free sampling | 44 | 6 | 6 | no | 14 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| HPH2008_2 | free sampling | 39 | 6 | 6 | no | 39 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| HPH2008_3 | free sampling | 40 | 6 | 6 | no | 100 | no | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| KPH2016_1 | free sampling | 104 | 114 | 114 | no | 21 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | yes | yes | no | 1 |
| L2010_2 | free sampling | 124 | 7 | 3 | yes | 41 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | multi-stage | 3 | between | Behavioral | yes | yes | no | 1 |
| LPFH2016_1 | free sampling | 30 | 9 | 9 | no | 19 | yes | 2 | 2 | both | partial | both               | both | variable | loss | single-stage | 2 | within | Behavioral | no | yes | no | 1 |
| MBDG2014_1 | free sampling | 294 | 16 | 2 | no | 10 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| NH2016_1 | free sampling | 131 | 786 | 6 | no | 18 | yes | 32 | 2 | dynamic | partial | numerical          | outcome | variable | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| NH2016_2 | free sampling | 101 | 786 | 6 | no | 15 | yes | 32 | 2 | dynamic | partial | numerical          | outcome | variable | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| PHKA2014_1 | free sampling | 180 | 20 | 5 | no | 6 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | mixed | single-stage | 2 | between | Behavioral | no | yes | variable | 1 |
| RDN2008_1 | free sampling | 80 | 12 | 6 | no | 16 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| WH2012_1 | free sampling | 186 | 6 | 6 | no | 14 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| WHH2015a_1 | free sampling | 63 | 10 | 10 | no | 21 | yes | 2 | 10 | stationary | partial | graphical          | outcome | risky_risky | gain | single-stage | 1 | within | Behavioral | yes | yes | yes | 1 |
| WHH2015b_1 | free sampling | 82 | 16 | 16 | no | 27 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| WHH2015b_2 | free sampling | 42 | 16 | 16 | no | 22 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| AKH2014_2 | lottery bandits | 60 | 2 | 1 | no | 80 | no | 3 | 2 | stationary | full | numerical          | outcome | risky_risky | mixed | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| AR2016_1 | lottery bandits | 51 | 14 | 14 | no | 40 | no | 2 | 2 | stationary | full | numerical          | outcome | variable | variable | single-stage | 1 | within | Psychophysiological | no | yes | variable | 0 |
| BE2003_2 | lottery bandits | 48 | 2 | 1 | no | 400 | no | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| BE2003_3 | lottery bandits | 48 | 2 | 1 | no | 400 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| BE2003_4 | lottery bandits | 60 | 2 | 1 | no | 400 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| BE2003_5 | lottery bandits | 48 | 3 | 1 | no | 400 | no | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 3 | between | Behavioral | no | yes | no | 0 |
| BY2009_2 | lottery bandits | 40 | 2 | 1 | no | 400 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | variable | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| CN2011b_2 | lottery bandits | 40 | 4 | 4 | no | 100 | no | 2 | 2 | stationary | both | numerical          | outcome | risky_safe | variable | single-stage | 2 | between | Behavioral | yes | no | no | 0 |
| CN2013_1 | lottery bandits | 203 | 32 | 8 | no | 40 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | yes | yes | no | 0 |
| EERH2010_3 | lottery bandits | 100 | 60 | 12 | no | 100 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| EEY2008_1 | lottery bandits | 45 | 4 | 4 | no | 99 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| FJM2011_1 | lottery bandits | 64 | 1 | 1 | no | 144 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | mixed | multi-stage | 4 | between | Behavioral | no | yes | no | 0 |
| HG2015_1 | lottery bandits | 100 | 1 | 1 | no | 100 | no | 2 | 3 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 1 | within | Behavioral | yes | yes | no | 0 |
| HG2015_2 | lottery bandits | 100 | 2 | 2 | no | 100 | no | 2 | 3 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 1 | within | Behavioral | yes | no | no | 0 |
| LG2011_1 | lottery bandits | 92 | 2 | 2 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | gain | single-stage | 3 | between | Behavioral | yes | no | no | 0 |
| LS2011_1 | lottery bandits | 61 | 10 | 10 | no | 19 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | yes | no | no | 0 |
| MEL2006_1 | lottery bandits | 54 | 1 | 1 | no | 100 | no | 2 | 2 | stationary | full | graphical          | outcome | risky_safe | loss | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| MEL2006_2 | lottery bandits | 24 | 1 | 1 | no | 100 | no | 2 | 2 | stationary | partial | graphical          | outcome | risky_safe | loss | single-stage | 1 | within | Behavioral | no | no | no | 0 |
| NE2012_1 | lottery bandits | 48 | 2 | 2 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | mixed | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| NE2012_2 | lottery bandits | 28 | 12 | 12 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| NEDO2012_1 | lottery bandits | 16 | 1 | 1 | no | 225 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | gain | single-stage | 1 | within | Behavioral | no | no | variable | 0 |
| RH2016_1 | lottery bandits | 75 | 3 | 1 | no | 12 | no | 2 | 3 | stationary | partial | numerical;food     | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| RH2016_2 | lottery bandits | 50 | 1 | 1 | no | 12 | no | 2 | 2 | dynamic | partial | numerical;food     | event | risky_safe | gain | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| SPAF2013_1 | lottery bandits | 20 | 4 | 2 | no | 60 | no | 2 | 2 | stationary | partial | numerical;food     | outcome | risky_safe | gain | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| SRE2014_1 | lottery bandits | 47 | 1 | 1 | no | 100 | no | 2 | 4 | stationary | full | graphical          | outcome | risky_safe | mixed | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| TAE2013_2 | lottery bandits | 40 | 4 | 4 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | mixed | single-stage | 2 | within | Behavioral | no | yes | no | 0 |
| TAE2013_3 | lottery bandits | 40 | 4 | 4 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_safe | mixed | single-stage | 2 | within | Behavioral | no | yes | no | 0 |
| YE2007_1 | lottery bandits | 24 | 4 | 4 | no | 100 | no | 3 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 2 | within | Behavioral | no | yes | no | 0 |
| YH2013_1 | lottery bandits | 122 | 4 | 1 | no | 100 | no | 2 | 2 | stationary | full | numerical          | outcome | risky_risky | variable | single-stage | 2 | between | Behavioral | no | yes | no | 0 |
| YH2013_4 | lottery bandits | 48 | 2 | 1 | no | 200 | no | 2 | 3 | stationary | full | numerical          | outcome | risky_risky | variable | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| YZA2015_1 | lottery bandits | 93 | 4 | 4 | no | 100 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| YZA2015_2 | lottery bandits | 95 | 4 | 4 | no | 100 | no | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| NNS2016_1 | observe or bet | 614 | 30 | 5 | no | 50 | no | 3 | 2 | both | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | no | yes | 0 |
| NNS2016_2 | observe or bet | 30 | 1 | 1 | no | 82 | no | 3 | 2 | stationary | full | graphical          | event | risky_risky | mixed | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| RNZ2010_1 | observe or bet | 24 | 6 | 6 | no | 69 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | mixed | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| RNZ2010_2 | observe or bet | 56 | 6 | 6 | no | 70 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | mixed | single-stage | 3 | between | Behavioral | no | yes | yes | 0 |
| GSR2006_1 | other | 80 | 2 | 2 | no | 192 | no | 2 | 2 | both | full | graphical          | event | risky_risky | gain | single-stage | 4 | between | Behavioral | no | yes | yes | 0 |
| GSR2006_2 | other | 80 | 2 | 2 | no | 192 | no | 2 | 2 | dynamic | full | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| MSBL2016_1 | other | 80 | 4 | 4 | no | 40 | no | 2 | 2 | stationary | other | numerical          | outcome | risky_risky | variable | single-stage | 2 | between | Behavioral;Clinical | no | no | yes | 0 |
| MSM2015_1 | other | 199 | 4 | 4 | no | 36 | no | 2 | 2 | stationary | other | numerical          | outcome | risky_risky | variable | single-stage | 2 | between | Behavioral | no | no | yes | 0 |
| SLO2014_1 | other | 40 | 1 | 1 | no | 44 | no | 2 | 2 | stationary | partial | graphical;physical | event | risky_risky | gain | single-stage | 3 | within | Behavioral | no | no | yes | 0 |
| SPP2014_1 | other | 20 | 1 | 1 | no | 72 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_risky | gain | multi-stage | 4 | within | MRI | no | yes | yes | 0 |
| TE2014_1 | other | 60 | 3 | 1 | no | 100 | no | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 0 |
| TE2014_2 | other | 60 | 3 | 1 | no | 50 | no | 2 | 2 | both | partial | numerical          | outcome | risky_risky | mixed | single-stage | 2 | within | Behavioral | no | yes | no | 0 |
| AK2011_2 | probability learning | 51 | 1 | 1 | no | 100 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| FMHC2007_1 | probability learning | 42 | 2 | 2 | no | 152 | yes | 6 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 2 | within | Behavioral;Genetics | no | no | yes | 0 |
| FSRW2007_1 | probability learning | 46 | 1 | 1 | no | 397 | yes | 6 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral;Clinical;Pharmacological | no | no | yes | 0 |
| G2016_1 | probability learning | 165 | 8 | 2 | no | 50 | no | 2 | 2 | stationary | partial | numerical          | event | risky_risky | gain | single-stage | 2 | within | Behavioral | no | no | yes | 0 |
| G2016_2 | probability learning | 40 | 4 | 4 | no | 25 | no | 2 | 2 | stationary | partial | numerical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | yes | 0 |
| GN2015_2 | probability learning | 15 | 9 | 9 | yes | 140 | yes | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| JKU2011_1 | probability learning | 16 | 2 | 2 | no | 352 | no | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 2 | within | MRI | no | yes | yes | 0 |
| KSO2006_1 | probability learning | 16 | 4 | 4 | no | 76 | no | 2 | 2 | stationary | other | graphical          | outcome | risky_risky | variable | single-stage | 4 | within | MRI | no | yes | yes | 0 |
| LLMB2017_1 | probability learning | 50 | 1 | 1 | no | 96 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | MRI | no | no | yes | 0 |
| LLMB2017_2 | probability learning | 35 | 1 | 1 | no | 94 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_risky | mixed | single-stage | 1 | within | MRI | no | no | yes | 0 |
| LT2012_1 | probability learning | 33 | 2 | 2 | no | 359 | no | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral;Clinical | no | no | yes | 0 |
| MDGB2014_1 | probability learning | 20 | 6 | 6 | no | 187 | yes | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 1 | within | MRI | no | yes | yes | 0 |
| NDGG2015_1 | probability learning | 22 | 1 | 1 | yes | 784 | yes | 3 | 2 | stationary | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | MRI | no | no | yes | 0 |
| ODSD2004_1 | probability learning | 12 | 1 | 1 | no | 138 | no | 2 | 2 | stationary | partial | food               | event | risky_risky | gain | single-stage | 1 | within | MRI | no | yes | yes | 0 |
| PKCB2016_1 | probability learning | 38 | 4 | 4 | no | 77 | no | 2 | 2 | stationary | both | numerical          | event | risky_risky | variable | single-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| PKJC2015_1 | probability learning | 28 | 16 | 16 | no | 384 | no | 2 | 2 | stationary | both | numerical          | outcome | risky_risky | variable | single-stage | 1 | within | MRI | no | yes | yes | 0 |
| RF2012_1 | probability learning | 30 | 1 | 1 | no | 1316 | yes | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | yes | 0 |
| RNW2015_1 | probability learning | 74 | 8 | 4 | no | 140 | yes | 2 | 2 | stationary | both | numerical          | outcome | risky_risky | mixed | multi-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| RNW2015_2 | probability learning | 77 | 4 | 4 | no | 320 | yes | 2 | 2 | stationary | both | numerical          | outcome | risky_risky | mixed | multi-stage | 1 | within | Behavioral | no | yes | yes | 0 |
| TMOP2015_1 | probability learning | 16 | 2 | 2 | no | 357 | no | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 2 | within | Transcranial | no | no | yes | 0 |
| TMPA2017_1 | probability learning | 29 | 2 | 2 | no | 355 | no | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 3 | within | Behavioral | no | yes | yes | 0 |
| VDO2007_1 | probability learning | 19 | 6 | 6 | no | 70 | no | 2 | 3 | stationary | partial | food               | event | risky_risky | variable | single-stage | 2 | between | fMRI | no | yes | yes | 0 |
| VO2009_1 | probability learning | 17 | 1 | 1 | no | 307 | no | 2 | 2 | stationary | partial | food;numerical     | both | risky_risky | gain | single-stage | 1 | within | fMRI | no | yes | yes | 0 |
| WM2014_1 | probability learning | 20 | 1 | 1 | no | 250 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | yes | 0 |
| WOCD2018_1 | probability learning | 33 | 2 | 2 | no | 125 | yes | 2 | 2 | stationary | partial | numerical          | event | risky_risky | gain | single-stage | 1 | within | Behavioral | no | no | yes | 0 |
| ZWLJ2012_1 | probability learning | 12 | 2 | 2 | no | 182 | yes | 2 | 2 | stationary | partial | graphical          | event | risky_risky | gain | single-stage | 1 | within | EEG | no | no | yes | 0 |
| CN2011a_1 | regulated sampling | 66 | 10 | 10 | no | 12 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| CN2011a_2 | regulated sampling | 36 | 10 | 10 | no | 20 | yes | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| HF2009_1 | regulated sampling | 111 | 3 | 3 | no | 20 | no | 2 | 2 | stationary | both | both               | both | variable | variable | single-stage | 4 | between | Behavioral | no | yes | no | 1 |
| RR2010_1 | regulated sampling | 101 | 4 | 4 | no | 20 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | gain | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| RR2010_2 | regulated sampling | 152 | 6 | 6 | no | 20 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | gain | single-stage | 3 | between | Behavioral | no | yes | no | 1 |
| RR2010_3 | regulated sampling | 71 | 6 | 6 | no | 20 | no | 2 | 2 | stationary | partial | numerical          | outcome | risky_safe | mixed | single-stage | 2 | between | Behavioral | yes | yes | no | 1 |
| UCS2009_1 | regulated sampling | 50 | 6 | 6 | no | 52 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 2 | between | Behavioral | no | yes | no | 1 |
| UCS2009_2 | regulated sampling | 197 | 6 | 1 | no | 80 | yes | 2 | 2 | stationary | partial | numerical          | outcome | variable | variable | single-stage | 1 | within | Behavioral | no | yes | no | 1 |
| SN2015_1 | social binary prediction | 60 | 1 | 1 | no | 200 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| SN2015_2 | social binary prediction | 60 | 1 | 1 | no | 200 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| SN2015_3 | social binary prediction | 60 | 1 | 1 | no | 200 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| SRN2015_1 | social binary prediction | 50 | 1 | 1 | no | 500 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |
| SRN2015_2 | social binary prediction | 50 | 1 | 1 | no | 300 | no | 2 | 2 | stationary | full | graphical          | event | risky_risky | gain | single-stage | 2 | between | Behavioral | no | yes | yes | 0 |

### Codebook for task features
1. **study**: Study identifier. Concatenation of the first letters of the first four authors’ last names, publication year, and study index. For example, AK2011_1 refers to the first study of Avrahami and Kareev (2011).
2. **paradigm**: Name of the paradigm category assigned to the study.
3. **n_participants**: Total number of participants in the experiment.
4. **n_problems**: Total number of problems in the experiment.
5. **n_problems_per_participant**: Number of problems completed by each participant. If participants completed a different number of problems, the largest number of problems is shown.
6. **problems_differ**: “yes” if the number of problems per participant experienced differs, otherwise “no”.
7. **n_trials**: The number of choices per problem. If the number of choices per problem varies between problems, the average number is returned.
8. **trials_differ**: “yes” if the number of trials per problem differs, otherwise “no”.
9. **n_options_per_problem**: Number of options per problem. If the number of options per problem varies between problems, the largest number is returned.
10. **n_outcomes_per_option**: Number of different outcomes per option. If the number of outcomes differs between options, the largest one is shown. The string “continuous” indicates options with continuous outcomes. 
11. **stationarity**: 
    - **“stationary”**: The options’ outcomes and probabilities are constant across trials or choices.  
    - **“dynamic”**: The options’ outcomes and/or probabilities change across trials or choices.
12. **feedback_format**:
    - **“partial”**: Only the outcome of their chosen option was displayed.
    - **“full”**: The outcomes of the chosen and non-chosen (forgone) option are displayed.
    - **“both”**: Participants receive partial feedback in some conditions and full feedback in others. 
    - **“none”**: No feedback about either the chosen or non-chosen option.
    - **“other”**: Other feedback types apart from those listed above.
13. **numerical_feedback**:
    - **“numerical”**: Feedback was a number (e.g., a numeric value or a number of points).
    - **“graphical”**: Feedback was an image (e.g., a picture of a one-dollar coin).
14. **feedback_type**: 
    - **“event”**: Feedback was binary (e.g., 0 versus 1, true versus false, or correct versus wrong).
    - **“value”**: Feedback was numerical (whole or real numbers).
15. **problem_type**: 
    - **“safe_safe”**: The problems contain only safe options. 
    - **“risky_safe”**: The problems contain safe and risky options. 
    - **“risky_risky”**: The problems contain only risky options. 
    - **“variable”**: The type differs between problems.
16. **problem_domain**: 
    - **“gain”**: The problems contain only positive outcomes. 
    - **“loss”**: The problems contain only negative outcomes. 
    - **“mixed”**: The problems contain both positive and negative outcomes. 
    - **“variable”**: The domain differs between problems.
17. **problem_stages**: 
    - **“single”**: Choices lead directly to payoff. 
    - **“multi”**: Choices (can) lead to second-order (higher-order) choice problems. Or problems have a follow-up phase which has different outcomes or feedback types.
18. **n_conditions**: The number of conditions.
19. **design**: “between” if conditions recorded vary between participants, otherwise “within”.
20. **study_context**:
    - **“behavioral”**
    - **“clinical”**
    - **“EEG”**
    - **“MRI” (incl. fMRI)**
    - **“transcranial”**
    - **“pharmacological”**
    - **“psychophysiological”**
    - **“genetics”**
21. **decisions_from_description**: “yes” if the study also involved choice in a decisions-from-description paradigm. 
22. **incentivization**: “yes” if participants' choices were monetarily or otherwise incentivized, otherwise “no”.  
23. **identical_outcome**: “yes” if all options share an identical set of outcomes (e.g., binary outcomes of 0 and 1), otherwise, “no”.
24. **sampling**: “yes” if participants are allowed to sample from options without consequences, or “no” if their choices are always consequential.
## Paradigm Definition
The studies in our database use dozens of different experimental tasks. In each task, researchers manipulate some variables and keep the others. This kind of feature combination leads to a variety of tasks that could be grouped into limited paradigms.  To help better communication, we grouped the tasks used in this database into 13 paradigms, each of which includes at least three studies. In this part, we will give the definition for each paradigm we have in this database. The paradigm is defined according to the task features and the original name given by authors, so the paradigm we assigned to the studies might be different from the name used in the original paper.</br>
</br>
For all paradigms, participants make a series of decisions from a set of options. Except for the two sampling paradigms, participants' decisions in other paradigms are consequential. We will only describe the difference below. </br>
</br>
1. **free sampling**: participants can freely sample from options to collect information without influencing their performance or payoff. After gathering enough information, participants make one final consequential decision.
2. **regulated sampling**: Similar to free sampling, except that after a predetermined number of samples (known or unknown to the participants), participants make one final consequential decision.
3. **lottery bandits**: Participants repeatedly choose between options with a small number of possible monetary outcomes with fixed probabilities. Every choice affects the final performance or payoff.
4. **continuous bandits**: At least one option has a continuous (= non-discrete) distribution of outcomes.
5. **dynamic bandits**: The outcome distribution of at least one option changes across the task.
6. **description bandits**: The outcome distribution is explicitly described to participants before they make decisions.
7. **probability learning**: Each of two or more options consists of a single outcome, materializing with distinct probabilities.
8. **dynamic probability learning**: A probability learning task where the probabilities change across trials.
9. **2-step dynamic probability learning**: A probability learning task with a two-step process, where the choice in the first step determines the options available in the second step.
10. **binary prediction**: Either one option with two potential outcomes or two options with perfectly dependent outcomes. The task is to predict which outcome will appear or which option will have the target outcome in the current trial.
11. **social binary prediction**: A binary prediction task with social context, usually involving two participants. Participants' outcomes are affected by the choices of the participants.
12. **observe or bet**: Participants can choose to observe, leading to a non-consequential choice with feedback (i.e., sampling), or can choose to bet, leading to a consequential choice without feedback.
13. **other**: Other paradigms that do not form a larger paradigm class. These paradigms occurred fewer than three times in our database.



