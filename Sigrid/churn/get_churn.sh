#!/bin/bash

# Author: Kirsten Gericke
# Software Improvement Group
# June 2024

# Requirements to run file:
#   1. write_results.py is in the current directory
#   2. Your SIGRID_CI_TOKEN is saved in your shell configuration file 
#       (please see https://docs.sigrid-says.com/organization-integration/authentication-tokens.html 
#       for instructions on creating a SigridCI Authentication Token)
#   2. .env file is set up with correct Sigrid tokens: 
#       (please see write_results.py for instructions on retrieving these tokens from your browser dev toolbar)
#        SSO_TOKEN
#        XSRF_TOKEN
#   3. Save SSO token to environment variables as well
#   3. chmod +x get_results.sh
#   4. ./get_results.sh  


# Lists
SYSTEMS=(
    'churn2-cbeanutils'
    'churn2-ccollections'
    'churn2-clang'
    'churn2-jodaconvert'
    'churn2-sudoku'
    'churn2-ccli'
    'churn2-cio'
    'churn2-cmath'
    'churn2-jodatime'
    )

REFACTORINGS=(
    'extractmethod'
    'extractvariable'
    'inline'
    'introduceindirection'
    'introducepo'
    'variabletofield'
)

CUSTOMER="sigdelivery"

for SYSTEM in "${SYSTEMS[@]}"; do
    cd ~/Desktop/uploads/Sahin/churn
    SYSTEM_BASE="${SYSTEM#churn2-}" # get rid of 'churn2-' in the front
    mkdir -p "${SYSTEM_BASE}" # make folder for each system
    cd "${SYSTEM_BASE}"
    for REFACTORING in "${REFACTORINGS[@]}"; do
        for i in {1..4}; do
            NAME="${SYSTEM}-${REFACTORING}-${i}"
            NAME_BASE="${NAME#churn2-}"
            echo $NAME

            # get delta quality results
            curl -X POST "https://sigrid-says.com/rest/analysis-results/changequality/sigdelivery/${NAME}" \
            -H 'content-type: application/json' \
            -H "cookie: ssoToken=${SSO_TOKEN}; XSRF-TOKEN=x" \
            -H 'x-xsrf-token: x' \
            --data-raw '{"startDate":"2024-06-11","endDate":"2024-06-13","changeQualityType":"NEW_AND_CHANGED_CODE_QUALITY"}'\
            | jq . > "churn-${NAME#churn2-}.json"

        done
    done
done

cd ~/Desktop/uploads/Sahin/churn

# create and activate venv
python3 -m venv virtualenv
source virtualenv/bin/activate

# install libraries
pip3 install python-dotenv  
pip3 install requests

#python3 get_osh_results.py 
python3 write_churn.py

    

