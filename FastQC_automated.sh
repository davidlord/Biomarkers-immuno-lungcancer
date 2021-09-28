#!/bin/bash

# Note: Requires that you are logged onto work node using 40 threads. 
# Requires the expect is installed on the work node. 
# Reqires that the directory /tmp/xlorda exists on the work node. 

# Change directory to tmp.
cd /tmp/xlorda

# Load fastqc
module load fastqc/0.11.9

# Enter folder list in loop. 
for FOLDERNAME in 2020-02-09 2020-04-07 2020-05-04 2021-02-27 2021-03-15 2021-06-02 2021-08-09 2021-08-27 2020-02-10 2020-04-17 2020-08-18 2021-03-01 2021-03-16 2021-07-19 2021-08-12 2020-02-12 2020-04-20 2020-12-17 2021-03-02 2021-04-23 2021-07-28 2021-08-13 2020-04-06 2020-04-22 2021-02-24 2021-03-03 2021-04-26 2021-08-08 2021-08-25;
do
# Integrate rsync into expect-block:
        /usr/bin/expect <<EOD
        spawn rsync -r -P xlorda@medair.sahlgrenska.gu.se:/seqstore/remote/share/AR_forskning/$FOLDERNAME/*.fastq.gz /tmp/xlorda/${FOLDERNAME}/
        # Prompt needs to be changed now that key has been added to ssh. 
        expect "xlorda@medair.sahlgrenska.gu.se's password:"
        send "PASSWORD\n"
        expect eof
        EOD

        # Run fastqc on loaded folder:
        fastqc -t 40 -o /home/xlorda/ /tmp/xlorda/${FOLDERNAME}/*.fastq.gz

        # Remove the folder: 
        rm ${FOLDERNAME}/*
        rmdir ${FOLDERNAME}

done
