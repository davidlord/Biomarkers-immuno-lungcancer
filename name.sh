#!/bin/bash

R=$1

function lib_extract
{
FIRST=${R#*lib}
LIBNAME=`echo ${FIRST%%_*}`
}

lib_extract $R 

echo $LIBNAME

