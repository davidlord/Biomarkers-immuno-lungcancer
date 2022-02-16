#!/bin/bash

# Script for fixing bug in VCF files (bug from Mutect2 pipeline).
 


INPUT=$1

sed -e 's/ID=AS_ReadPosRankSum,Number=A/ID=AS_ReadPosRankSum,Number=./' -e 's/ID=AS_FilterStatus,Number=A/ID=AS_FilterStatus,Number=./' -e 's/ID=AS_MQ,Number=A/ID=AS_MQ,Number=./' -e 's/ID=AS_SB_TABLE,Number=1/ID=AS_SB_TABLE,Number=./' -e 's/ID=AS_UNIQ_ALT_READ_COUNT,Number=A/ID=AS_UNIQ_ALT_READ_COUNT,Number=./' $INPUT > ${INPUT%.vcf}.debugged.vcf



