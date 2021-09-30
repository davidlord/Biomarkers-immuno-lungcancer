#!/bin/bash -l

# Note: Requires that you are logged onto work node using 40 threads.

# Change directory to tmp.
cd /tmp/xlorda

# Load fastqc
module load fastqc/0.11.9

# Define expect-rsync function
function f_rsync
{
/usr/bin/expect <<EOF
set timeout -1
spawn rsync -P xlorda@medair.sahlgrenska.gu.se:/seqstore/remote/share/AR_forskning/$FOLDERNAME/*fastq.gz ./$FOLDERNAME
expect "Enter passphrase for key '/home/xlorda/.ssh/id_rsa':"
# Can direct password to a private password file for security reasons
send "PASSWORD\n"
expect eof
wait
EOF
}

for FOLDERNAME in 2020-02-09 2020-02-10 2020-02-12 2020-04-06 2020-04-07 2020-04-17 2020-04-20 2020-04-22 2020-05-04 2020-08-18 2020-08-19 2020-08-21 2020-08-28 2020-11-02 2020-11-20 2020-12-17 2021-01-26 2021-02-24 2021-02-27 2021-03-01 2021-03-02 2021-03-03 2021-03-15 2021-03-16 2021-04-23 2021-04-26 2021-05-29 2021-05-31 2021-06-02 2021-07-19 2021-07-28 2021-08-08 2021-08-09 2021-08-12 2021-08-13 2021-08-25 2021-08-27;
do
        mkdir $FOLDERNAME
        echo Running expect-rsync
        f_rsync
        echo Running FastQC
        fastqc -t 40 -o /home/xlorda/ /tmp/xlorda/${FOLDERNAME}/*.fastq.gz
        echo Removing files and dir
        rm ${FOLDERNAME}/*
        rmdir ${FOLDERNAME}
        echo Done with one cycle

done
