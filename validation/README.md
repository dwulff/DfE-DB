# Validation
In this section, we validate our processed data in three ways: Whether the outcome distribution is consistent with reported in the paper, whether participants choose the option with a higher expected value more often than by chance, whether participants choose the option with a higher mean value more often than by chance. With these validations, we can check whether there is any coding mistake in the raw data or whether we processed the raw data incorrectly. </br>
## Process
Our data contains different types of decision-making tasks, and the distribution of the feedback values is also various. Based on the outcome distribution, we divided all studies into three categories: studies with stationary and discontinuous outcomes, studies with stationary and continuous outcomes, and studies with dynamic outcomes. You can find different validation scripts for these three kinds of studies in the validation folder. </br>
</br>
For studies with stationary and discontinuous outcome values, you can use 'validation_stationary.py'. Because the distribution of the outcome value is recorded in the option table in a standard machine-readable format. We can use one code to process all data in this category. With this code, we validate the processed data one paradigm at a time. Here, we provide an example of validation studies in all relevant paradigm. If you want to validate a specific paradigm, you should change the paradigm name in line 67 to the paradigm you want to validate.</br>
</br>
For studies with stationary and continuous outcome values, you can use the scripts in the continuous folder. These studies have a stationary outcome distribution. However, this distribution can not be recorded in the standard machine-readable format. Therefore, we write the distribution manually in the validation scripts in the continuous folder. You can find one script for each study with continuous outcome distribution.</br>
</br>
For studies with dynamic outcome values, you can use 'validation_dynamic.py'. Studies in this category have neither a stationary outcome distribution nor an option with clearly higher expected value. Therefore, for studies with dynamic outcome distribution, we only test whether participants choose the option with a higher mean value more often than by chance.</br>

Results are presented below. You can also find these information in 'validation_result.csv' </br>

### Validation Result Table
| study | paradigm | consistent_outcomes | consistent_probabilities | consistent_probabilities_problem | high_ev_choices | high_ev_choices_problems | high_mean_choices | high_mean_choices_problems | note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| DBDF2016_1 | 2 step dynamic probability learning | nan | nan | nan | nan | nan | 0.59 | 1.0 | nan |
| KCG2016_1 | 2 step dynamic probability learning | nan | nan | nan | nan | nan | nan | nan | new Daw task, no choice in stage 2 |
| KCG2016_2 | 2 step dynamic probability learning | nan | nan | nan | nan | nan | 0.57 | 1.0 | nan |
| AK2011_1 | binary prediction | 1.0 | 0.0 | 0.0 | 0.643 | 1.0 | 0.625 | 1.0 | nan |
| BE1998_1 | binary prediction | 1.0 | 0.0 | 0.0 | 0.848 | 1.0 | 0.819 | 1.0 | nan |
| GN2015_1 | binary prediction | nan | nan | nan | nan | nan | nan | nan | Special problem, no validation info |
| GS2008_1 | binary prediction | 1.0 | 0.224 | 0.0 | 0.479 | 0.0 | 0.488 | 0.0 | nan |
| GS2008_2 | binary prediction | 1.0 | 0.082 | 0.0 | 0.715 | 1.0 | 0.711 | 1.0 | nan |
| LDP2011_1 | binary prediction | 1.0 | 0.008 | 0.0 | 0.935 | 1.0 | 0.53 | 0.25 | nan |
| NKJR2013_2 | binary prediction | 1.0 | 0.0 | 0.0 | 0.855 | 1.0 | 0.727 | 1.0 | nan |
| OTM2011_1 | binary prediction | 1.0 | 0.0 | 0.0 | 0.617 | 1.0 | 0.611 | 1.0 | nan |
| SKH2014_1 | binary prediction | 1.0 | 0.001 | 0.0 | 0.703 | 1.0 | 0.578 | 0.667 | nan |
| SKH2014_2 | binary prediction | 1.0 | 0.0 | 0.0 | 0.7 | 1.0 | 0.612 | 0.667 | nan |
| BE2003_1 | continuous bandits | 0.667 | 0.0 | 0.0 | 0.555 | 0.333 | 0.638 | 0.667 | the maximum value of A is a little bit higher than 3 standard deviation. No problem. |
| CGDW2014_1 | continuous bandits | 1.0 | 0.0 | 1.0 | 0.68 | 1.0 | 0.683 | 1.0 | nan |
| EEY2008_3 | continuous bandits | 0.5 | 0.0 | 0.25 | 0.48 | 0.25 | 0.564 | 1.0 | nan |
| WM2014_2 | continuous bandits | 0.0 | 0.0 | 1.0 | 0.735 | 1.0 | 0.73 | 1.0 | nan |
| YB2008_1 | continuous bandits | 0.667 | 0.0 | 0.333 | 0.5 | 0.333 | 0.594 | 1.0 | have some outlier |
| YB2008_2 | continuous bandits | 0.667 | 0.0 | 0.333 | 0.479 | 0.667 | 0.647 | 1.0 | have some outlier |
| YE2007_2 | continuous bandits | 1.0 | 0.0 | 0.0 | 0.3 | 0.0 | 0.464 | 1.0 | nan |
| JBB2008_1 | description bandits | 1.0 | 0.007 | 0.0 | 0.563 | 0.5 | 0.574 | 1.0 | nan |
| JBB2010_1 | description bandits | 1.0 | 0.01 | 0.0 | 0.492 | 0.0 | 0.51 | 0.0 | nan |
| TAE2013_1 | description bandits | 1.0 | 0.0 | 0.0 | 0.386 | 0.0 | 0.464 | 0.0 | nan |
| YB2006_1 | description bandits | 1.0 | 0.0 | 0.0 | 0.44 | 0.25 | 0.515 | 0.5 | nan |
| YBE2005_1 | description bandits | 1.0 | 0.001 | 0.0 | 0.69 | 1.0 | 0.454 | 0.0 | nan |
| YDE2008_1 | description bandits | 1.0 | 0.0 | 0.0 | 0.644 | 1.0 | 0.449 | 0.5 | nan |
| YDE2008_2 | description bandits | 1.0 | 0.0 | 0.0 | 0.446 | 0.0 | 0.33 | 0.0 | nan |
| BEE2009_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.515 | 1.0 | nan |
| BEE2009_2 | dynamic bandits | nan | nan | nan | nan | nan | 0.786 | 1.0 | nan |
| BWGN2013_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.321 | 1.0 | nan |
| HE2013_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.785 | 1.0 | nan |
| HE2013_2 | dynamic bandits | nan | nan | nan | nan | nan | 0.887 | 1.0 | nan |
| ICRS2015_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.508 | 0.667 | nan |
| ICRS2015_2 | dynamic bandits | nan | nan | nan | nan | nan | 0.506 | 0.667 | nan |
| KOSL2012_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.546 | 1.0 | nan |
| LLG2014_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.634 | 1.0 | nan |
| OKML2014_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.52 | 1.0 | nan |
| OKML2014_2 | dynamic bandits | nan | nan | nan | nan | nan | 0.571 | 0.5 | nan |
| RM2009_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.617 | 1.0 | nan |
| RM2009_2 | dynamic bandits | nan | nan | nan | nan | nan | 0.583 | 1.0 | nan |
| SK2015_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.514 | 1.0 | nan |
| ST2009_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.252 | 0.0 | remaind trials depends on previous choices, reward point consist. Different estimation method. Consist with raw data.  |
| WM2012_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.334 | 1.0 | nan |
| WM2014_3 | dynamic bandits | nan | nan | nan | nan | nan | 0.542 | 1.0 | nan |
| WMM2008_1 | dynamic bandits | nan | nan | nan | nan | nan | 0.537 | 0.333 | nan |
| WMM2008_2 | dynamic bandits | nan | nan | nan | nan | nan | 0.537 | 0.333 | nan |
| CDFO2012_1 | dynamic probability learning | nan | nan | nan | nan | nan | 0.5 | 0.5 | nan |
| DSCA2015_1 | dynamic probability learning | nan | nan | nan | nan | nan | 0.572 | 1.0 | nan |
| LLLH2014_1 | dynamic probability learning | nan | nan | nan | nan | nan | 0.538 | 1.0 | nan |
| PLKB2017_1 | dynamic probability learning | nan | nan | nan | nan | nan | 0.514 | 0.5 | nan |
| PLKB2017_2 | dynamic probability learning | nan | nan | nan | nan | nan | 0.635 | 1.0 | nan |
| SNJG2013_1 | dynamic probability learning | nan | nan | nan | nan | nan | 0.589 | 1.0 | nan |
| WRO2009_1 | dynamic probability learning | nan | nan | nan | nan | nan | 0.507 | 0.0 | decision made using hand or eye movement, not really free choices (forced choices as well), full reward instead of full feedback |
| CN2009a_1 | free sampling | 1.0 | 0.0 | 0.0 | 0.489 | 0.375 | 0.333 | 0.0 | nan |
| CN2009b_1 | free sampling | 1.0 | 0.003 | 0.0 | 0.589 | 0.625 | 0.368 | 0.0 | nan |
| CN2011b_1 | free sampling | 1.0 | 0.0 | 0.0 | 0.481 | 0.333 | 0.457 | 0.25 | nan |
| FAOV2014_1 | free sampling | 1.0 | 0.0 | 0.0 | 0.507 | 0.417 | 0.308 | 0.0 | nan |
| FHR2014_1 | free sampling | 1.0 | 0.0 | 0.0 | 0.516 | 0.25 | 0.366 | 0.0 | nan |
| FHR2014_2 | free sampling | 1.0 | 0.0 | 0.0 | 0.504 | 0.444 | 0.338 | 0.0 | nan |
| FMH2015_1 | free sampling | 1.0 | 0.001 | 0.0 | 0.514 | 0.5 | 0.308 | 0.0 | nan |
| FMH2015_2 | free sampling | 1.0 | 0.042 | 0.0 | 0.505 | 0.129 | 0.313 | 0.023 | nan |
| GFHA2012_1 | free sampling | 1.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.302 | 0.0 | nan |
| GHHF2016_1 | free sampling | 1.0 | 0.002 | 0.0 | 0.498 | 0.22 | 0.294 | 0.0 | nan |
| GHHF2016_2 | free sampling | 1.0 | 0.001 | 0.0 | 0.501 | 0.3 | 0.307 | 0.0 | nan |
| GHHF2016_3 | free sampling | 1.0 | 0.002 | 0.0 | 0.513 | 0.293 | 0.335 | 0.0 | nan |
| GM2016_1 | free sampling | 1.0 | 0.004 | 0.0 | 0.49 | 0.0 | 0.351 | 0.0 | nan |
| GM2016_2 | free sampling | 1.0 | 0.0 | 0.0 | 0.482 | 0.0 | 0.52 | 0.75 | nan |
| HBWE2004_1 | free sampling | 1.0 | 0.003 | 0.0 | 0.499 | 0.5 | 0.339 | 0.0 | nan |
| HNG2013_1 | free sampling | 1.0 | 0.009 | 0.0 | 0.122 | 0.0 | 0.134 | 0.6 | nan |
| HP2010_1 | free sampling | 1.0 | 0.001 | 0.0 | 0.514 | 0.25 | 0.293 | 0.0 | nan |
| HPH2008_1 | free sampling | 1.0 | 0.003 | 0.0 | 0.354 | 0.167 | 0.268 | 0.0 | nan |
| HPH2008_2 | free sampling | 1.0 | 0.001 | 0.0 | 0.372 | 0.5 | 0.299 | 0.0 | nan |
| HPH2008_3 | free sampling | 1.0 | 0.001 | 0.0 | 0.421 | 0.333 | 0.459 | 0.0 | nan |
| KPH2016_1 | free sampling | 1.0 | 0.001 | 0.0 | 0.503 | 0.41 | 0.313 | 0.009 | nan |
| L2010_2 | free sampling | 1.0 | 0.034 | 0.0 | 0.49 | 0.2 | 0.375 | 0.0 | nan |
| LPFH2016_1 | free sampling | nan | nan | nan | nan | nan | 0.357 | 0.0 | All outcome in database all represent by the evaluated number given by participants.Numerical outcome differs between participants.  |
| MBDG2014_1 | free sampling | 1.0 | 0.001 | 0.0 | 0.498 | 0.188 | 0.429 | 0.0 | nan |
| NH2016_1 | free sampling | nan | nan | nan | nan | nan | 0.497 | 0.0 | Randomly drawn outcome value.132 regard A_B and A_A_B_B as same question. conditions: small or large set. raw data, problem number variad. |
| NH2016_2 | free sampling | nan | nan | nan | nan | nan | 0.501 | 0.0 | Randomly drawn outcome value. |
| PHKA2014_1 | free sampling | 1.0 | 0.008 | 0.0 | 0.533 | 0.3 | 0.254 | 0.0 | nan |
| RDN2008_1 | free sampling | 1.0 | 0.002 | 0.0 | 0.521 | 0.25 | 0.286 | 0.0 | nan |
| WH2012_1 | free sampling | 1.0 | 0.0 | 0.0 | 0.487 | 0.0 | 0.345 | 0.0 | unpublished raw data |
| WHH2015a_1 | free sampling | 1.0 | 0.001 | 0.0 | 0.505 | 0.125 | 0.324 | 0.0 | nan |
| WHH2015b_1 | free sampling | 1.0 | 0.004 | 0.0 | 0.576 | 0.75 | 0.435 | 0.062 | nan |
| WHH2015b_2 | free sampling | 1.0 | 0.008 | 0.0 | 0.551 | 0.75 | 0.404 | 0.0 | nan |
| AKH2014_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.341 | 0.5 | 0.391 | 1.0 | nan |
| AR2016_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.549 | 0.714 | 0.558 | 0.857 | nan |
| BE2003_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.571 | 0.5 | 0.574 | 0.5 | nan |
| BE2003_3 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.614 | 1.0 | 0.614 | 1.0 | nan |
| BE2003_4 | lottery bandits | 1.0 | 0.0 | 0.0 | nan | nan | 0.621 | 1.0 | nan |
| BE2003_5 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.326 | 0.0 | 0.627 | 1.0 | nan |
| BY2009_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.513 | 0.5 | 0.558 | 0.5 | nan |
| CN2011b_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.448 | 0.333 | 0.625 | 1.0 | nan |
| CN2013_1 | lottery bandits | 1.0 | 0.001 | 0.0 | 0.505 | 0.5 | 0.455 | 0.125 | nan |
| EERH2010_3 | lottery bandits | 1.0 | 0.001 | 0.0 | 0.56 | 0.517 | 0.696 | 0.983 | nan |
| EEY2008_1 | lottery bandits | 1.0 | 0.0 | 0.0 | nan | nan | 0.554 | 1.0 | nan |
| FJM2011_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.455 | 0.0 | 0.411 | 0.0 | nan |
| HG2015_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.665 | 1.0 | 0.592 | 1.0 | nan |
| HG2015_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.615 | 1.0 | 0.543 | 1.0 | nan |
| LG2011_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.489 | 0.5 | 0.596 | 1.0 | nan |
| LS2011_1 | lottery bandits | 1.0 | 0.003 | 0.0 | 0.894 | 1.0 | 0.433 | 0.333 | nan |
| MEL2006_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.681 | 1.0 | 0.594 | 1.0 | nan |
| MEL2006_2 | lottery bandits | 1.0 | 0.001 | 0.0 | 0.453 | 0.0 | 0.523 | 1.0 | nan |
| NE2012_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.367 | 0.0 | 0.564 | 1.0 | nan |
| NE2012_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.59 | 0.75 | 0.605 | 0.917 | nan |
| NEDO2012_1 | lottery bandits | 1.0 | 0.001 | 0.0 | 0.884 | 1.0 | 0.445 | 0.5 | nan |
| RH2016_1 | lottery bandits | nan | nan | nan | nan | nan | nan | nan | no numerical outcome |
| RH2016_2 | lottery bandits | 1.0 | 0.001 | 0.0 | 0.603 | 1.0 | 0.33 | 0.0 | nan |
| SPAF2013_1 | lottery bandits | 1.0 | 0.004 | 0.0 | nan | nan | 0.405 | 0.0 | nan |
| SRE2014_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.204 | 0.0 | 0.447 | 0.0 | nan |
| TAE2013_2 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.361 | 0.0 | 0.557 | 0.75 | nan |
| TAE2013_3 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.31 | 0.0 | 0.506 | 0.5 | nan |
| YE2007_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.441 | 1.0 | 0.485 | 1.0 | nan |
| YH2013_1 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.635 | 1.0 | 0.65 | 1.0 | nan |
| YH2013_4 | lottery bandits | 1.0 | 0.0 | 0.0 | 0.661 | 1.0 | 0.657 | 1.0 | nan |
| YZA2015_1 | lottery bandits | 1.0 | 0.0 | 0.0 | nan | nan | 0.536 | 1.0 | nan |
| YZA2015_2 | lottery bandits | 1.0 | 0.0 | 0.0 | nan | nan | 0.538 | 1.0 | nan |
| NNS2016_1 | observe or bet | nan | nan | nan | nan | nan | 0.316 | 0.0 | nan |
| NNS2016_2 | observe or bet | 1.0 | 0.0 | 0.0 | 0.653 | 1.0 | 0.528 | 1.0 | nan |
| RNZ2010_1 | observe or bet | 1.0 | 0.001 | 0.0 | 0.725 | 1.0 | 0.398 | 0.0 | nan |
| RNZ2010_2 | observe or bet | 1.0 | 0.001 | 0.0 | 0.719 | 1.0 | 0.445 | 0.167 | nan |
| GSR2006_1 | other | nan | nan | nan | nan | nan | 0.61 | 1.0 | nan |
| GSR2006_2 | other | nan | nan | nan | nan | nan | 0.285 | 1.0 | 1 late reversion task. Dynamic feedback. Checked. Consist with raw data. |
| MSBL2016_1 | other | 1.0 | 0.0 | 0.0 | 0.564 | 0.75 | 0.49 | 0.5 | nan |
| MSM2015_1 | other | 1.0 | 0.0 | 0.0 | 0.632 | 1.0 | 0.444 | 0.5 | nan |
| SLO2014_1 | other | 1.0 | 0.0 | 0.0 | 0.764 | 1.0 | 0.755 | 1.0 | nan |
| SPP2014_1 | other | 1.0 | 0.002 | 0.0 | 0.658 | 0.917 | 0.53 | 0.417 | nan |
| TE2014_1 | other | 1.0 | 0.0 | 0.0 | 0.748 | 1.0 | 0.609 | 1.0 | nan |
| TE2014_2 | other | nan | nan | nan | nan | nan | 0.56 | 0.333 | partly yoked group; three levels of reward probability |
| AK2011_2 | probability learning | 1.0 | 0.0 | 0.0 | 0.651 | 1.0 | 0.643 | 1.0 | nan |
| FMHC2007_1 | probability learning | 1.0 | 0.001 | 0.0 | 0.659 | 1.0 | 0.609 | 1.0 | nan |
| FSRW2007_1 | probability learning | 1.0 | 0.0 | 0.0 | 0.61 | 1.0 | 0.596 | 1.0 | nan |
| G2016_1 | probability learning | 1.0 | 0.0 | 0.0 | 0.55 | 0.875 | 0.494 | 0.375 | nan |
| G2016_2 | probability learning | 1.0 | 0.004 | 0.0 | 0.669 | 1.0 | 0.56 | 1.0 | nan |
| GN2015_2 | probability learning | nan | nan | nan | nan | nan | 0.517 | 0.333 | Special problem planet decision, distribution not reported in paper |
| JKU2011_1 | probability learning | 1.0 | 0.002 | 0.0 | 0.834 | 1.0 | 0.827 | 1.0 | nan |
| KSO2006_1 | probability learning | 1.0 | 0.007 | 0.0 | 0.568 | 0.5 | 0.509 | 0.5 | nan |
| LLMB2017_1 | probability learning | 1.0 | 0.003 | 0.0 | 0.761 | 1.0 | 0.527 | 0.75 | nan |
| LLMB2017_2 | probability learning | 1.0 | 0.002 | 0.0 | 0.746 | 1.0 | 0.487 | 0.5 | nan |
| LT2012_1 | probability learning | 1.0 | 0.0 | 0.0 | 0.57 | 0.667 | 0.552 | 0.667 | nan |
| MDGB2014_1 | probability learning | 1.0 | 0.049 | 0.0 | 0.517 | 0.667 | 0.591 | 1.0 | response freely during a specific perioud of time |
| NDGG2015_1 | probability learning | nan | nan | nan | nan | nan | 0.337 | 0.0 | find target feature first. Distribution not reported |
| ODSD2004_1 | probability learning | 1.0 | 0.002 | 0.0 | 0.547 | 0.5 | 0.512 | 0.5 | nan |
| PKCB2016_1 | probability learning | 1.0 | 0.001 | 0.0 | 0.685 | 1.0 | 0.608 | 0.5 | nan |
| PKJC2015_1 | probability learning | 1.0 | 0.001 | 0.0 | 0.789 | 1.0 | 0.705 | 0.75 | nan |
| RF2012_1 | probability learning | nan | nan | nan | nan | nan | 0.717 | 0.231 | nan |
| RNW2015_1 | probability learning | 1.0 | 0.001 | 0.0 | 0.665 | 1.0 | 0.527 | 0.812 | nan |
| RNW2015_2 | probability learning | nan | nan | nan | nan | nan | nan | nan | feedback on stage 1 not 2 |
| TMOP2015_1 | probability learning | 1.0 | 0.601 | 0.0 | 0.798 | 1.0 | 0.4 | 0.0 | nan |
| TMPA2017_1 | probability learning | 1.0 | 0.001 | 0.0 | 0.763 | 1.0 | 0.755 | 1.0 | nan |
| VDO2007_1 | probability learning | nan | nan | nan | nan | nan | nan | nan | no numerical outcome; CD only trian, HD only test. devalued vs valued |
| VO2009_1 | probability learning | 1.0 | 0.002 | 0.0 | 0.625 | 0.75 | 0.569 | 0.5 | nan |
| WM2014_1 | probability learning | 1.0 | 0.001 | 0.0 | 0.719 | 1.0 | 0.71 | 1.0 | nan |
| WOCD2018_1 | probability learning | 1.0 | 0.014 | 0.0 | 0.66 | 0.667 | 0.582 | 0.333 | nan |
| ZWLJ2012_1 | probability learning | 1.0 | 0.008 | 0.0 | 0.61 | 1.0 | 0.569 | 0.333 | nan |
| CN2011a_1 | regulated sampling | 1.0 | 0.001 | 0.0 | 0.557 | 0.75 | 0.345 | 0.0 | nan |
| CN2011a_2 | regulated sampling | 1.0 | 0.004 | 0.0 | 0.505 | 0.0 | 0.246 | 0.0 | nan |
| HF2009_1 | regulated sampling | 1.0 | 0.0 | 0.0 | 0.5 | 0.0 | 0.329 | 0.0 | nan |
| RR2010_1 | regulated sampling | 1.0 | 0.001 | 0.0 | nan | nan | 0.348 | 0.0 | nan |
| RR2010_2 | regulated sampling | 1.0 | 0.0 | 0.0 | nan | nan | 0.36 | 0.0 | nan |
| RR2010_3 | regulated sampling | 1.0 | 0.001 | 0.0 | 0.5 | 0.0 | 0.325 | 0.0 | nan |
| UCS2009_1 | regulated sampling | 1.0 | 0.0 | 0.0 | 0.502 | 0.167 | 0.3 | 0.0 | nan |
| UCS2009_2 | regulated sampling | 1.0 | 0.0 | 0.0 | 0.5 | 0.0 | 0.462 | 0.167 | nan |
| SN2015_1 | social binary prediction | 1.0 | 0.001 | 0.0 | 0.789 | 1.0 | 0.749 | 1.0 | nan |
| SN2015_2 | social binary prediction | 1.0 | 0.0 | 0.0 | 0.671 | 1.0 | 0.66 | 1.0 | nan |
| SN2015_3 | social binary prediction | 1.0 | 0.001 | 0.0 | 0.726 | 1.0 | 0.592 | 1.0 | nan |
| SRN2015_1 | social binary prediction | 1.0 | 0.0 | 0.0 | 0.789 | 1.0 | 0.766 | 1.0 | nan |
| SRN2015_2 | social binary prediction | 1.0 | 0.0 | 0.0 | 0.809 | 1.0 | 0.788 | 1.0 | nan |

### Codebook
1. **study**: Study identifier. Concatenation of the first letters of the authors’ last names, publication year, and study index. For example, AK2011_1 refers to the first study of Avrahami and Kareev (2011).
2. **paradigm**: Name of the paradigm category assigned to the study.
3. **consistent outcomes**: Proportion of problems where the experienced outcomes strictly matched the outcomes in the options table.
4. **consistent probabilities**: The average normalized chi-square testing the experienced relative frequencies against the true probabilities in the options table.
5. **consistent probabilities problem**: Proportion of problems where the experienced relative frequencies deviated from the true probabilities in the options table based on alpha = .01.  
6. **high ev choices**:Overall proportion higher-expected-value option.
7. **high ev choices problems**: Proportion of problems with above-chance choices of the higher-expected-value option. 
8. **high mean choices**: Proportion of choices of the option with the higher-experienced-mean option.
9. **high mean choices problems**: Proportion of problems with above-chance choices of the higher-experienced-mean option.
10. **note**: Further information about this study.

