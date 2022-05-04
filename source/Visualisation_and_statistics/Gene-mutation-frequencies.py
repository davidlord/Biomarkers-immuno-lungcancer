#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import pandas as pd
import glob
from functools import reduce

# Set work dir (where mutation tsv files are located).
# DEV: Move this to config file.
work_dir = "/Users/davidlord/Documents/External_data/script_running/"
os.chdir(work_dir)

# Read  data file
total_df = pd.read_csv("total_df.tsv", sep = '\t')

# Store gene-mutation column names in a list
gene_mut_cols = ['POLE', 'KEAP1', 'KRAS', 'POLD1', 'STK11', 'TP53', 'MSH2', 'EGFR', 'PTEN']
ind = ['Study_ID'] + gene_mut_cols

# Subset dataframe
mutations_df = total_df[ind]

# Get study IDs
studyids = mutations_df.Study_ID.unique()
studyids = studyids.tolist()






