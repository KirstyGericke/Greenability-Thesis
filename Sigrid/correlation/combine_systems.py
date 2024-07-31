# Author: Kirsten Gericke
# Software Improvement Group
# June 2024

import os
import pandas as pd

# Define the base directory
base_dir = "path_to_base_directory"

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
        df = pd.read_csv(csv_path)
        
        # Rename the 'Value' column to the system name
        df.rename(columns={'Value': system}, inplace=True)
        
        # Merge with the combined DataFrame
        if combined_df.empty:
            combined_df = df
        else:
            combined_df = pd.merge(combined_df, df[['Metric', system]], on='Metric', how='outer')

# Save the combined DataFrame to a CSV file
combined_df.to_csv(os.path.join(base_dir, "combined_systems.csv"), index=False)
