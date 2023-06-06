# About
This project was created for the course Network Science (LTAT.02.011) taught at University of Tartu in Spring 2023.

This repository contains all of the work done for the project by its sole author. The root of the repository contains the network analysis itself (Network_analysis.ipynb), as well as the adjacency matrices used for the network analyses.
- cormatrix.csv contains the correlation matrix of the self-report personality item ratings
- cormatrixCharacters contains the correlation matrix of mean fictional character ratings
- measures.csv contains the list of items used within the questionnaire and the formulation of the adjective pairs.

To run the analysis itself, simply open the file Network_analysis, and run the individual cells in order. There may be an issue with the node embedding section due to dependencies that may have arisen since publication that I have not managed to find a consistent solution to, but installing all the versions of the packages used for this section in a random order before re-installing the required version seems to resolve the issue.


### Data  generation

The data-generating procedure takes a long time (approx 10 hours), but the network analysis itself can be done with the uploaded files already present, and the Rscript is included for completeness and reproducibility. 

The folder Network Estimation contains the R script Complete_data-generation_network-estimation.R used to compile the data used for network estimation and the network estimation procedure itself (computation of pairwise correlations) used in the analysis. The original datasets are too large to be uploaded to github. The data can be re-created from the .RDS files included in the folder structure, or the original dataset can be downloaded from https://openpsychometrics.org/tests/characters/data/:
- https://openpsychometrics.org/tests/characters/data/SWCPQ-Features-Aggregated-Dataset.zip contains the file characters-aggregated-scores.csv which contains the mean fictional character ratings across the 400 items.
- https://openpsychometrics.org/tests/characters/data/SWCPQ-Features-Survey-Dataset-July2022.zip contains the file features-survey-dataset.csv which contains the raw individual self-report responses.
