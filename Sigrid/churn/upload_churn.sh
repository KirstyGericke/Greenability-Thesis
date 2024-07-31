#!/bin/bash

###
# TODO before uploading:
# 1. make sure YAML files are correct and in correct directories
# 2. remove already uploaded systems from directory
# 3. Run file using:
#       chmod +x upload_churn.sh
#       ./upload_churn.sh  

# Remember: to view churn, upload the two versions on different days
###

########################
# Code for uploading Sahin systems
########################

cd ~
cd sigridci

OUTER_DIRECTORY="/Users/kirstengericke/Repositories/Sahin" #directory storing all system to be uploaded
LOCATIONS=() # Array to store paths to folders to upload to sigrid

# | OUTER DIRECTORY  eg. /Users/kirstengericke/Repositories/Sahin
# |----- DIRECTORY   eg. /Users/kirstengericke/Repositories/Sahin/CBeanutils
# |---------- FOLDER eg. /Users/kirstengericke/Repositories/Sahin/CBeanutils/cBeanutils_original

COUNT=0
for DIRECTORY in "$OUTER_DIRECTORY"/*/; do
    DIRECTORY=${DIRECTORY%/}
    # this is needed for original uploads
    for FOLDER in "$DIRECTORY"/*/; do
        if [[ "$FOLDER" == *original/ ]]; then
            ORIGINAL_LOCATION="$FOLDER"
        fi
    done 
    for FOLDER in "$DIRECTORY"/*/; do
        echo "$FOLDER"
        # upload original files to sigrid but name them the names of the refactored versions
        for LOCATION in "${FOLDER[@]}"; do
            BASENAME=$(basename "$LOCATION" | tr '_' '-') # Extract the basename and replace underscores with hyphens
            SYSTEM="churn2-$BASENAME" # Construct the SYSTEM variable
            echo "Uploading $SYSTEM from $LOCATION"
            # NB! Change the location to either LOCATION or ORIGINAL_LOCATION
            ./sigridci/sigridci/sigridci.py --customer sigdelivery --system ${SYSTEM} --source ${LOCATION} --publish
            ((COUNT++))
            echo "Uploaded: $COUNT/206"
       done
    done
done





