import os
import pandas as pd
import glob
from functools import reduce

# Set work dir (where mutation tsv files are located).
# DEV: Move this to config file.
work_dir = "/Users/davidlord/Documents/External_data/script_running/"
os.chdir(work_dir)


# Read clinical data table as df:
# DEV: Move to config file. 
clinical_df = pd.read_csv("cbioportal_clinical_data.tsv", sep = '\t')
# Remove duplicates (in regards to sample ID) from clinical df:
clinical_df = clinical_df.drop_duplicates(subset = ['Sample_ID'], keep = 'first')
# Read sample IDs from clinical df as list:
clin_sampleIDs_list = clinical_df["Sample_ID"].tolist()


# Read all mutation file names in dir to list
mutation_tables_list = glob.glob("*.mutation.tsv")


### For each mutations tsv file; look at sampleIDs, if sampleID present in clinical df; 
### set samplID  value to 1 (mutation present), else set sapleID value to 0 (mutation not present); 
### store in one dataframe per tsv file; store dataframes in dataframes list.

# Initialize a list to store dataframes in:
temp_df_list = []
# Initialize a list to store sample IDs from mutations tsv files in:
mutations_sampleIDs_list = []
for mutations_table in mutation_tables_list:
    # Get mutation name.
    # DEV: Better fix using regex rather than subsetting string.
    mutation_name = mutations_table[:4]
    # read as df: 
    mutations_df = pd.read_csv(mutations_table, sep = '\t')
    # Filter for somatic variants: 
    mutations_df_somatic = mutations_df[mutations_df["MS"] == "SOMATIC"]
    # Convert mutations sample ID column to list: 
    mutations_sampleIDs_list = mutations_df_somatic["Sample ID"].tolist()
    # Create an empty dict to store mutation boolean data for each sample ID in:
    mutations_sampleID_dict = {}
    # Store sample ID from clinical data sets in dict.
    # If mutation present in sample, sampleID = 1, else sampleID = 0
    for sampleID in clin_sampleIDs_list:
        if sampleID in mutations_sampleIDs_list:
            mutations_sampleID_dict[sampleID] = 1
        else:
            mutations_sampleID_dict[sampleID] = 0
    # Convert dict to df:
    df = pd.DataFrame(list(mutations_sampleID_dict.items()), columns = ["Sample_ID", mutation_name + "_mut"])
    temp_df_list.append(df)

# Merge all dataframes (generated in previous loop) stored in temp_df_list to single dataframe:
all_muts_df = reduce(lambda l, r: pd.merge(l, r, on = 'Sample_ID', how = 'inner'), temp_df_list)

# Merge to mutations dataframe to clinical dataframe:
merged_df = pd.merge(clinical_df, all_muts_df, on = 'Sample_ID')

# Save as tsv file:
merged_df.to_csv("merged_cBioPortal_clinical_mutation_data.tsv", sep = '\t', index = False)

###
