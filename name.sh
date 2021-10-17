#!/bin/bash

# Set variable for input
R=$1

# Set variable for path to read files
FILE_PATH=/home/xlorda/anna_tmp/mapped_bam_files

# Create a function to extract library name
function lib_extract
{
FIRST=${R#*lib}
LIBNAME=`echo ${FIRST%%_*}`
}

lib_extract $R

echo $LIBNAME




# Create function to extract read group platform(?)
function rgpu_extract
{
FIRST=${R#*N?-}
RGPU=`echo ${FIRST%%_*}`
}

rgpu_extract $R

echo $RGPU



# Create function to extract sample name
function samplename_extract
{
FIRST=${R#*[0-9]_}
SAMPLENAME=`echo ${FIRST%%lib*}`
}
samplename_extract $R

echo $SAMPLENAME



