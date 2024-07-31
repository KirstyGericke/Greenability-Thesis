# Author: Kirsten Gericke
# Software Improvement Group
# June 2024

#!/usr/bin/python3
import os
import json
import csv
import requests
import datetime
from dotenv import load_dotenv
from collections import defaultdict

def combine_churn_results(input_directory):
    #results = defaultdict(lambda: defaultdict(lambda: [0, 0, 0, 0]))  # [count, totalNewFiles, totalNewVolumeInMonths, totalNewVolumeInLoc]
    results = defaultdict(lambda: [0, 0, 0, 0])  # [count, totalNewFiles, totalNewVolumeInMonths, totalNewVolumeInLoc]
    
    
    output_file = os.path.join(input_directory, 'churn.csv')
    for system in sorted(os.listdir(input_directory)):
        system_path = os.path.join(input_directory, system)
        if system != 'virtualenv' and os.path.isdir(system_path):
            csv_file = os.path.join(system_path, 'churn-' + system + '.csv')  # eg. cbeanutils.csv
            if os.path.isfile(csv_file):
                with open(csv_file, 'r') as f:
                    reader = csv.DictReader(f)
                    for row in reader:
                        key = (row['System'], row['Refactoring'])

                        if (row['Refactoring']!="extractvariable"):
                            results[key][0] += 1  # Increment count
                        else:
                            # account for extractvariable not being implemented 4 times in all systems
                            if(int(row['totalNewFiles'])!=0): 
                                results[key][0] += 1  # Increment count

                        results[key][1] += int(row['totalNewFiles'])
                        results[key][2] += float(row['totalNewVolumeInMonths'])
                        results[key][3] += int(row['totalNewVolumeInLoc'])
    
    with open(output_file, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['System', 'Refactoring', 'average totalNewFiles', 'average totalNewVolumeInMonths', 'average totalNewVolumeInLoc'])
        
        for (system, refactoring), (count, total_files, total_months, total_loc) in results.items():
            if(count!=0): # only if the refactoring was implemented at least once
                avg_files = total_files / count
                avg_months = total_months / count
                avg_loc = total_loc / count
                writer.writerow([system, refactoring, avg_files, avg_months, avg_loc])
            else:
                writer.writerow([system, refactoring, 0, 0, 0])
         

def write_churn(input_directory):
    for system in sorted(os.listdir(input_directory)): 
        system_path = os.path.join(input_directory, system) # eg. uploads/sahin/cbeanutils
        if system!='virtualenv' and os.path.isdir(system_path): # only look at folders not files
            csv_file = os.path.join(system_path, 'churn-' + system + '.csv')  # eg. cbeanutils.csv
            with open(csv_file, 'w', newline='') as cf:
                    writer = csv.writer(cf)
                    writer.writerow([
                                    'System',
                                    'Refactoring', 
                                    'Refactoring Number', 
                                    'totalNewFiles', 
                                    'totalNewVolumeInMonths', 
                                    'totalNewVolumeInLoc'
                                    ]) 
            for json_file in sorted(os.listdir(system_path)): 
                if json_file.endswith('.json'):
                    
                    refactoring = '-'.join(json_file.split('-')[2:]).rstrip('.json') # get rid of system name at beginning and .json at end
                    refactoring_name, refactoring_number = refactoring.rsplit('-', 1)  # Split the refactoring name and number
                    json_file_path = os.path.join(system_path, json_file)
                    
                    try:
                        with open(json_file_path, 'r') as jf:
                            data = json.load(jf)
                    except json.JSONDecodeError:  # Handle empty or invalid JSON files
                        data = None

                    with open(csv_file, 'a', newline='') as cf:
                        writer = csv.writer(cf)
                        if data is None or not data:
                            writer.writerow([
                                system, 
                                refactoring_name, 
                                refactoring_number,  
                                0, 0, 0
                            ])
                        else:
                            writer.writerow([
                                system, 
                                refactoring_name, 
                                refactoring_number, 
                                data.get('totalNewFiles', 0), 
                                data.get('totalNewVolumeInMonths', 0), 
                                data.get('totalNewVolumeInLoc', 0)
                            ])

################################
# Main
################################

if __name__ == "__main__":
    input_directory = os.path.expanduser('~/Desktop/uploads/Sahin/churn')
    write_churn(input_directory)
    combine_churn_results(input_directory)