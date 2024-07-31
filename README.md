
# Table of Contents
- [Table of Contents](#table-of-contents)
- [Details](#details)
- [Description](#description)
- [Repository Organisation](#repository-organisation)
- [File Descriptions](#file-descriptions)
  - [First Experiment files](#first-experiment-files)
    - [get\_results.sh](#get_resultssh)
    - [write\_results.py](#write_resultspy)
- [Requirements to execute files](#requirements-to-execute-files)
  - [get\_results.sh](#get_resultssh-1)
  - [write\_results.py](#write_resultspy-1)
    - [NB!!](#nb)
  - [Contact](#contact)
  - [Project status](#project-status)

# Details

- **Author:** Kirsten Gericke
- **Company:** Software Improvement Group
- **Team:** Green IT
- **Supervisors:** Chushu Gao and Pepijn van de Kamp
- **Date:** May 2024
- **Thesis Topic:** Software Greenability Measurement Model

# Description
Publicly available repositories of systems containing before and after versions of files that have been refactored to improve their energy consumption are compiled and analysed in order to find a correlation between Energy Reduction Potential and Greenability Metrics. 

# Repository Organisation

- `first experiment` contains the files for uploading 22 systems from 3 papers and calculating their greenability scores.
- `churn experiment` contains the files for uploading 9 applications that were refactored 4 times by 9 refactoring patterns, calculating their greenability and churn results, and the correlation tests.

# File Descriptions

## First Experiment files
The order and purpose of the files in this repo are as follows: 

1. The system files were uplaoded to Sigrid, SIG's quality analysis tool. This process was completed using `upload_system.sh`. 

2. After the systems were uploaded and had time to be analysed, `get_results.sh` exported these results into json files and saved into `json_outputs`. 

3. `get_results.sh` then executes `write_results.py`, which collects the relevant metrics from the `json` files and from Sigrid, and saves them into one `csv` file per system. Considering not all metrics measured by Sigrid are relevant to Greenability, only a selection of metrics were converted into csv files (found in their respective folders containing the json outputs). 

4. `write_results.py` calculates Maintainability, Measureability, Reliability and Freshness scores for each system and saves them into `greenability_scores.csv`. 

### get_results.sh

This file performs the following tasks: 
1. Calls the Sigrid internal API to retrieve Reliability results, and writes them to a `json` file for each system
2. Calls the Sigrid external API to retrieve Maintainability, Open Source Health and Architecture results, and writes them to a `json` file for each system
3. Sets up virtual environment
4. Executes `write_results.py`

### write_results.py

This file performs the following tasks: 
1. sends a GET request for osh metrics from Sigirid 
2. reads Sigrid metrics from json files created by `get_results.sh`
3. writes only the Greenability metrics to a csv file for each system 
4. calculates the scores for Greenability properties
5. calcualtes the overall greenability score for each system
6. writes all scores for all systems into one csv file


# Requirements to execute files

## get_results.sh

   1. `write_results.py` is in the same directory as `get_results.py`
   2. Your `SIGRID_CI_TOKEN` is saved in your shell configuration file 
       (please see https://docs.sigrid-says.com/organization-integration/authentication-tokens.html 
       for instructions on creating a SigridCI Authentication Token)
   2. `.env` file is set up with correct Sigrid tokens: 
       (please see [requirements `write_results.py`](#write_resultspy-1) for instructions on retrieving these tokens from your browser dev toolbar)
        `SSO_TOKEN`
        `XSRF_TOKEN`
   3. `chmod +x get_results.sh`
   4. `./get_results.sh `

## write_results.py

1. This file is executed by `get_results.sh`, which means all the json files will be in their respective folders for each system being analysed
2. Set up `.env` file
    - Log in to Sigrid
    - Navigate to the Open Source Health results for any system in `sigdelivery`
    - Open the browser's dev toolbar (inspect page)
    - Refresh page
    - Select Network
    - Select the API request with the following details:
        - Title: system-{SYSTEM}
        - Request URL: https://sigrid-says.com/rest/analysis-results/libraryDependencies/sigdelivery/system-{SYSTEM}}
    - Copy the value of Request Headers > Cookie > ssoToken 
    - Copy the value of Response Headers > Set-Cookie > XSRF-TOKEN
    - Set the two tokens in a .env file:
        - `XSRF_TOKEN="..."`
        - `SSO_TOKEN="..."`

### NB!!
1.  Make sure the two tokens are not declared as an environment variable in your terminal.
    (it will overwrite the venv tokens)
2.  The tokens expire when your sigrid session expires, 
    which means you will have to reset the tokens.
    You need to close and reopen terminal when you do this to save the changes.


## Contact
Email: Kirsten.gericke@softwareimprovementgroup.com

## Project status
- First experiement: Uploaded files, exported results, calculated Greenability scores, calculated correlation with energy consumption and scores for inital set of 18 systems. 
- Churn experiement: Uploaded 197 files (9 apps x 6 refactorings x 4 iterations), calculated their greenability and churn results, and performed correlation tests on multiple variables. 
- Now in the process of expanding the data set and analysing the correlation test results.
- finished!