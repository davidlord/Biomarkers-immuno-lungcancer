#!/bin/bash

R=$1


function samplename_extract
{
FIRST=${R#*lib}
${FIRST%%_*}
}

libname=$( libname_extract $R )

