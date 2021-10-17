#!/bin/bash

R=$1

function samplename_extract
{
FIRST=${R#*lib}
${FIRST%%_*}
}
SAMPLENAME=$( samplename_extract $R )

echo $SAMPLENAME









