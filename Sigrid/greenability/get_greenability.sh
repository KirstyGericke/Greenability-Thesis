#!/bin/bash

# Author: Kirsten Gericke
# Software Improvement Group
# June 2024

# Requirements to run file:
#   1. write_greenability.py is in the current directory
#   2. Your SIGRID_CI_TOKEN is saved in your shell configuration file 
#       (please see https://docs.sigrid-says.com/organization-integration/authentication-tokens.html 
#       for instructions on creating a SigridCI Authentication Token)
#   2. .env file is set up with correct Sigrid tokens: 
#       (please see write_greenability.py for instructions on retrieving these tokens from your browser dev toolbar)
#        SSO_TOKEN
#        XSRF_TOKEN
#   3. chmod +x get_greenability.sh
#   4. ./get_greenability.sh  

SIGRID_CI_TOKEN=$SIGRID_CI_TOKEN
CUSTOMER="sigdelivery"

# Lists
QUALITIES=(
    'maintainability' 
    'security-findings' 
    'reliability-findings' 
    'osh-findings' 
    'architecture-quality'
    )

SYSTEMS=(
    'churn2-cbeanutils-original'
    'churn2-ccollections-original'
    'churn2-clang-original'
    'churn2-jodaconvert-original'
    'churn2-sudoku-original'
    'churn2-ccli-original'
    'churn2-cio-original'
    'churn2-cmath-original'
    'churn2-jodatime-original'
    )

cd ~/Desktop/uploads/Sahin/greenability

# iterate over all possible qualities and systems
for SYSTEM in "${SYSTEMS[@]}"; do
    
    SYSTEM_BASE="${SYSTEM#churn2-}" # get rid of 'churn2-' in the front
    SYSTEM_BASE="${SYSTEM_BASE#churn2-}"
    mkdir -p "${SYSTEM_BASE%-original}" # make folder for each system

    # get reliability results from internal API
    URL="https://sigrid-says.com/rest/analysis-results/api/v1/model-ratings/${CUSTOMER}/${SYSTEM}?feature=RELIABILITY"
     # Execute the curl command and save the result to a file
        if curl -H curl -H "Authorization: Bearer ${SIGRID_CI_TOKEN}" "${URL}" | jq '.' >  "$(pwd)/${SYSTEM_BASE}/${SYSTEM_BASE}_internal_reliability-findings.json"; then
            echo "Results written for ${SYSTEM_BASE}: Internal Reliabilty Rating"
        else
            echo "Failed to fetch results for ${SYSTEM_BASE}: Internal Reliabilty Rating" >&2
        fi

    # get all other results from external API
    for QUALITY in "${QUALITIES[@]}"; do
        # URL that calls the Sigrid API
        URL="https://sigrid-says.com/rest/analysis-results/api/v1/${QUALITY}/${CUSTOMER}/${SYSTEM}"
        # Execute the curl command and save the result to a file
        if curl -H "Authorization: Bearer ${SIGRID_CI_TOKEN}" "${URL}" > "$(pwd)/${SYSTEM_BASE}/${SYSTEM_BASE}_${QUALITY}.json"; then
            echo "Sigrid ouput successfully written for ${SYSTEM_BASE}: ${QUALITY}"
        else
            echo "Failed to fetch results from Sigrid for ${SYSTEM_BASE}: ${QUALITY}" >&2
        fi
    
    done
done

# create and activate venv
python3 -m venv virtualenv
source virtualenv/bin/activate

# install libraries
pip3 install python-dotenv  
pip3 install requests

#python3 get_osh_results.py 
python3 write_greenability.py

