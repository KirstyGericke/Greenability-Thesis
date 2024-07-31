#!/usr/bin/python3
import os
import pandas as pd
import json
import csv
import requests
import datetime
from dotenv import load_dotenv

# Author: Kirsten Gericke
# Software Improvement Group
# June 2024

'''
This file performs the following tasks: 
1. sends a GET request for osh metrics from Sigirid 
2. reads Sigrid metrics from json files already collected earlier
3. writes only the Greenability metrics to a csv file for each system 
4. calculates the scores for Greenability properties
5. calcualtes the overall greenability score for each system
6. writes all scores for all systems into one csv file

To Run file:
1. This file is executed by get_results.sh, which means all the json files will be in 
    their respective folders for each system being analysed
2. Set up .env file
    - Log in to Sigrid
    - Navigate to the Open Source Health results for any system in sigdelivery 
    - Open the inspector 
    - Refresh page
    - Select Network
    - Select the API request with the following details:
        Title: system-{SYSTEM}
        Request URL: https://sigrid-says.com/rest/analysis-results/libraryDependencies/sigdelivery/system-{SYSTEM}}
    - Copy the value of Request Headers > Cookie > ssoToken 
    - Copy the value of Response Headers > Set-Cookie > XSRF-TOKEN
    - Set the two tokens in a .env file:
        XSRF_TOKEN="..."
        SSO_TOKEN="..."
3. write correct input directory in main

NB!!
1.  Make sure the two tokens are not declared as an environment variable in your terminal.
    (it will overwrite the venv tokens)
2.  The tokens expire when your sigrid session expires, 
    which means you will have to reset the tokens.
    You need to close and reopen terminal when you do this to save the changes!


This file is structured as follows:
1. Lists of metrics needed from json files for main Greenability properties:
    measurability_metrics
    maintainability_metrics
    freshness_metrics
    reliability_metrics
2. Functions for calculating Greenability:
    calculate_score()
    get_volume_pm()
    write_headings()
    write_system_scores()
    calculate_greenability()
3. Functions for writing metrics:
    write_maintainability_metrics_to_csv()
    write_osh_metrics_to_csv()
    write_reliability_metrics_to_csv()
    write_architecture_metrics_to_csv()
    json_to_csv()
4. Main

'''

################################
# Metrics needed from json files for main Greenability properties
################################

measurability_metrics=[
                        'unitInterfacing',
                        'moduleCoupling',
                        'componentIndependence',
                        'componentEntanglement',
                        'codeBreakdown',
                        'componentCoupling', 
                        'testCodeRatio',
                        'freshness',
                        'technologyPrevalence'
                        ]

maintainability_metrics=[
                        'volume',
                        'duplication',
                        'unitSize',
                        'unitComplexity',
                        'unitInterfacing',
                        'moduleCoupling',
                        'componentIndependence',
                        'componentEntanglement',
                        'codeBreakdown',
                        'componentCoupling',
                        'testCodeRatio'
                        ]   

architecture_metrics=[
                        "codeBreakdown",
                        "componentCoupling",
                        "technologyPrevalence",
                        "componentCohesion",
                        "codeReuse",
                        "communicationCentralization",
                        "dataCoupling",
                        "boundedEvolution",
                        "knowledgeDistribution",
                        "componentFreshness"
                        ] 
osh_metrics=[
                        "outdatedRating",
                        "unmanagedRating",
                        "unmaintainedRating"

                        ]

# osh metrics:
        # outdatedRating = freshness risk
        # unmaintainedRating = activity risk
        # unmanagedRating = management risk

freshness_metrics=[
                        'freshness', 
                        'technologyPrevalence'
                        ]       

reliability_metrics=['reliability']             

################################
# Get OSH results: please read instructions for setting tokens 
################################

def get_osh_results(input_directory):
    load_dotenv()
    sigrid_XSRF_token = os.getenv("XSRF_TOKEN")
    sigrid_SSO_token = os.getenv("SSO_TOKEN")

    customer = "sigdelivery"
    current_date = datetime.datetime.now().strftime("%Y-%m-%d")

    cookies = {
        'XSRF-TOKEN': sigrid_XSRF_token,
        'ssoToken': sigrid_SSO_token,
    }

    headers = {
        'Content-Type': 'application/json',
    }

    for system_name in os.listdir(input_directory):
        system_path = os.path.join(input_directory, system_name) #eg. ../json_ouputs/bayes
        if system_name!='virtualenv' and os.path.isdir(system_path): # only look at folders not files
            print(system_name)
            response = requests.get(
                f'https://sigrid-says.com/rest/analysis-results/libraryDependencies/{customer}/{system_name}?startDate={current_date}&endDate={current_date}',
                cookies=cookies,
                headers=headers
            )
            response_dict = response.json()
            file_path = os.path.join(system_path, f"{system_name}_internal_osh-findings.json")
            with open(file_path, "w") as json_file:
                # Convert dictionary to JSON string and write it to the file
                json.dump(response_dict, json_file)
                print(f'OSH results successfully written for {system_name}.')

################################
# Functions for calculating Greenability
################################

# get list of metric values needed for a property, and return the average
def calculate_score(csv_file, metrics):
    total_sum = 0
    count = 0
    with open(csv_file, mode='r') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) >= 2 and row[0] in metrics and row[1]!='NA':
                total_sum += float(row[1])
                count +=1
    if count==0:
        return 0
    else:
        return total_sum/count

# Volume in Person Months is not needed for calculation, but is interesting to see in csv
def get_volume_pm(system_path):
    for quality_file in os.listdir(system_path):
        if quality_file.endswith('maintainability.json'):
            json_file = os.path.join(system_path, quality_file)
            with open(json_file, 'r') as jf:
                data = json.load(jf) 
            return data.get('volumeInPersonMonths', 0)

def write_headings(csv_file):
    # write headings of columns for csv file:
    with open(csv_file, 'w', newline='') as cf: # 'w' cause first time writing
        writer = csv.writer(cf) 
        writer.writerow([
                        'System Name', 
                        'Volume (PM)',
                        'Maintainability Score', 
                        'Measurability Score', 
                        'Freshness Score', 
                        'Reliability Score', 
                        'Greenability Score'
                        ]) 

def write_system_scores(system, csv_file, csv_location, system_path):
    # values in put in csv:
    maintainability_score = calculate_score(csv_location, maintainability_metrics)
    measurability_score = calculate_score(csv_location, measurability_metrics)
    freshness_score = calculate_score(csv_location, freshness_metrics)
    reliability_score = calculate_score(csv_location, reliability_metrics)
    volume_PM = get_volume_pm(system_path)

    # calcuate greenability:
    scores = [
            maintainability_score, 
            measurability_score, 
            freshness_score,
            reliability_score
            ]
    greenability_score = sum(scores)/len(scores) # for some reason I cant install numpy

    # write one row in csv file per system:
    with open(csv_file, 'a', newline='') as cf: # 'a' cause appending
        writer = csv.writer(cf)
        writer.writerow([
                        system.split('-')[1],
                        volume_PM,
                        maintainability_score,
                        measurability_score,
                        freshness_score,
                        reliability_score,
                        greenability_score,
                    ]) 
        print(f'Greenability metrics successfully written for {system}')

def calculate_greenability(input_directory, csv_file):
    for system in os.listdir(input_directory):
        system_path = os.path.join(input_directory, system) #eg. ../json_ouputs/bayes
        if system!='virtualenv' and os.path.isdir(system_path): # only look at folders not files
            for quality_file in os.listdir(system_path): # go through files in system folder
                # get quality metric results
                if quality_file.endswith('.csv'): # skip json files
                    csv_location = os.path.join(system_path, quality_file) #eg. ../json_ouputs/bayes/bayes.csv
                    write_system_scores(system, csv_file, csv_location, system_path) # write scores for single system

def write_all_scores(input_directory, csv_destination):
    for system in os.listdir(input_directory):
        system_path = os.path.join(input_directory, system) #eg. ../json_ouputs/bayes
        if system!='virtualenv' and os.path.isdir(system_path): # only look at folders not files
            for quality_file in os.listdir(system_path): # go through files in system folder
                # get quality metric results
                if quality_file.endswith('.csv'): # skip json files
                    csv_source = os.path.join(system_path, quality_file) #eg. ../json_ouputs/bayes/bayes.csv
                    with open(csv_destination, 'a', newline='') as cf: # 'a' cause appending
                        writer = csv.writer(cf)
                        
                        writer.writerow([
                                        system.split('-')[1],
                                        volume_PM,
                                        maintainability_score,
                                        measurability_score,
                                        freshness_score,
                                        reliability_score,
                                        greenability_score,
                                    ]) 


################################
# Functions for writing metrics
################################

def write_maintainability_metrics_to_csv(json_file, csv_file):
    maintainability_metrics = [
        'maintainability',
        'componentIndependence',
        'componentEntanglement',
        'duplication',
        'moduleCoupling',
        'testCodeRatio',
        'unitComplexity',
        'unitInterfacing',
        'unitSize',
        'volume',
        ]

    with open(json_file, 'r') as jf:
        data = json.load(jf) # Read the JSON file

    # Open the CSV file for writing
    # can use w cause its the first time writing to the file
    with open(csv_file, 'w', newline='') as cf:
        writer = csv.writer(cf)
        
        # Write a header for the maintainability metrics section
        #writer.writerow(['Maintainability Metrics'])
        #writer.writerow(['metric', 'value'])  # Sub-header for this section

        # Write the maintainability metrics and their values to the CSV file
        for metric in maintainability_metrics:
            if metric in data:
                writer.writerow([metric, data[metric]])
            else:
                writer.writerow([metric, 'N/A'])  # or an appropriate placeholder

        # Add a blank line to separate sections
        #writer.writerow([])

def write_osh_metrics_to_csv(json_file, csv_file):
    osh_metrics=[
                        'outdatedRating',
                        'unmanagedRating',
                        'unmaintainedRating'
                        ]
    # osh metrics:
        # outdatedRating = freshness risk
        # unmaintainedRating = activity risk
        # unmanagedRating = management risk
    with open(json_file, 'r') as jf:
        data = json.load(jf) # Read the JSON file
    with open(csv_file, 'a', newline='') as cf:
        writer = csv.writer(cf)
        #writer.writerow(['Open Source Health Metrics'])
        #writer.writerow(['metric', 'value'])  # Sub-header for this section
        
        freshness_rating = data.get('ratings', {}).get('outdatedRating', {}).get('value')
        writer.writerow(['Freshness Risk', freshness_rating])  
        
        activity_rating = data.get('ratings', {}).get('unmaintainedRating', {}).get('value')
        writer.writerow(['Activity Risk', activity_rating])

        management_rating = data.get('ratings', {}).get('unmanagedRating', {}).get('value')
        writer.writerow(['Management Risk', management_rating])
        
        #writer.writerow([])

def write_reliability_metrics_to_csv(json_file, csv_file):
    with open(json_file, 'r') as jf:
        data = json.load(jf) # Read the JSON file

    with open(csv_file, 'a', newline='') as cf:
        writer = csv.writer(cf)
        #writer.writerow(['Reliability Metrics'])
        #writer.writerow(['metric', 'value'])  # Sub-header for this section
        writer.writerow(['reliability', data.get('rating', 0)]) 
        #writer.writerow([])

def write_architecture_metrics_to_csv(json_file, csv_file):
    architecture_metrics=[
                        'architecture',
                        'codeBreakdown',
                        'componentCoupling',
                        'technologyPrevalence',
                        'componentCohesion',
                        'codeReuse',
                        'communicationCentralization',
                        'dataCoupling',
                        'boundedEvolution',
                        'knowledgeDistribution',
                        'componentFreshness'
                        ] 
    with open(json_file, 'r') as jf:
        data = json.load(jf) # Read the JSON file

    # use 'a' this time to not overwrite previous written metrics
    with open(csv_file, 'a', newline='') as cf:
        writer = csv.writer(cf)

        # Write a header for the architecture metrics section
        #writer.writerow(['Architecture Metrics'])
        #writer.writerow(['metric', 'value'])  # Sub-header for this section

        # Write the architecture metrics and their values to the CSV file
        for metric in architecture_metrics:
            if metric == 'architecture': 
                if metric in data['ratings']:
                    writer.writerow([metric, data['ratings'][metric]])
                else:
                    writer.writerow([metric, 'N/A'])  # or an appropriate placeholder
            elif metric in data['ratings']['systemProperties']:
                writer.writerow([metric, data['ratings']['systemProperties'][metric]])
            else:
                writer.writerow([metric, 'N/A'])  # or an appropriate placeholder

        # Add a blank line to separate sections
        #writer.writerow([])

# Write one csv file for each system with all metrics for that system
def json_to_csv(input_directory):
    for system in sorted(os.listdir(input_directory)): # Iterate over the systems and qualities directories

        system_path = os.path.join(input_directory, system) # eg. json_ouputs/bayes
        
        if system!='virtualenv' and os.path.isdir(system_path): # only look at folders not files
            csv_file = os.path.join(system_path, system + '.csv')  # save the CSV in the same directory

            maintainability_file = os.path.join(system_path, system+'_maintainability.json') # eg. json_ouputs/bayes/bayes_maintainability.json
            architecture_file = os.path.join(system_path, system+'_architecture-quality.json')
            osh_file = os.path.join(system_path, system+'_internal_osh-findings.json')
            reliability_file = os.path.join(system_path, system+'_internal_reliability-findings.json')

            if os.path.isfile(maintainability_file):
                write_maintainability_metrics_to_csv(maintainability_file, csv_file)

            if os.path.isfile(reliability_file):
                write_reliability_metrics_to_csv(reliability_file, csv_file)

            if os.path.isfile(architecture_file):
                write_architecture_metrics_to_csv(architecture_file, csv_file)

            if os.path.isfile(osh_file):
                write_osh_metrics_to_csv(osh_file, csv_file)
            else:
                print('Failed to find ' + osh_file)

def combine_all_metrics(input_directory):
    base_dir = input_directory
    # List of system names based on folder names
    systems = [
        "cbeanutils",
        "ccli",
        "ccollections",
        "cio",
        "clang",
        "cmath",
        "jodaconvert",
        "jodatime",
        "sudoku"
    ]

    # Initialize an empty DataFrame for the combined data
    combined_df = pd.DataFrame()

    # Iterate over each system to read its CSV and merge into the combined DataFrame
    for system in systems:
        # Construct the CSV file path
        csv_path = os.path.join(base_dir, f"churn2-{system}-original", f"churn2-{system}-original.csv")
        
        # Read the CSV file
        if os.path.exists(csv_path):
            df = pd.read_csv(csv_path, header=None, names=['metric', 'value'])
            
            # Assuming the first column is the metric and the second column is the value
            metric_col = df.columns[0]
            value_col = df.columns[1]
            
            # Rename the value column to the system name
            df.rename(columns={value_col: system}, inplace=True)
            
            # Merge with the combined DataFrame
            if combined_df.empty:
                combined_df = df
            else:
                combined_df = pd.merge(combined_df, df[[metric_col, system]], on=metric_col, how='outer')

        else:
            print("Can't find system: ", csv_path)

    # Save the combined DataFrame to a CSV file
    combined_df.to_csv(os.path.join(base_dir, "combined_systems.csv"), index=False)


################################
# Main
################################

if __name__ == "__main__":
    input_directory = os.path.expanduser('~/Desktop/uploads/Sahin/greenability')
    get_osh_results(input_directory) # please read .env token instructions!
    json_to_csv(input_directory)
    csv_file = os.path.join(input_directory, 'greenability_scores.csv') # create one file with all main property values  
    write_headings(csv_file)
    calculate_greenability(input_directory, csv_file)
    combine_all_metrics(input_directory)
