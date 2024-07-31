#!/bin/bash

###
# TODO before uploading:
# 1. make sure YAML files are correct and in correct directories
# 2. remove already uploaded systems from directory
# 3. Run file using:
#       chmod +x upload_systems.sh
#       ./upload_systems.sh  
###

########################
# Code for uploading original systems
########################

cd ~
cd sigridci

DIRECTORY="/Users/kirstengericke/Systems" #directory storing all system to be uploaded
LOCATIONS=() # Array to store paths to folders to upload to sigrid

# Loop through each folder in the directory
for FOLDER in "$DIRECTORY"/*/; do
    LOCATIONS+=("$FOLDER") # Add the folder path to the array
done

# upload original files to sigrid
for LOCATION in "${LOCATIONS[@]}"; do
    SYSTEM="system-$(basename "$LOCATION")"
    #echo "Uploading $SYSTEM from $LOCATION"
    ./sigridci/sigridci/sigridci.py --customer sigdelivery --system ${SYSTEM} --source ${LOCATION} --publish
done
