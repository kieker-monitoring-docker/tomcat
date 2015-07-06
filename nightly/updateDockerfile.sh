#!/bin/bash
# Author: Thomas F. Düllmann
# Description:
#  This script retrieves the latest (nightly) Kieker AspectJ JAR 
#  from the oss.sonatype.org repository. 
#  To achieve this the metadata files are read to find out the latest version 
#  and further date/build information to pick the right (latest) file available. 

# Greps the first given input ($1) with the second ($2), removes all HTML tags and removes spaces
function stripHtml {
  echo `cat $1 | grep $2 | sed -e 's/<[^>]*>//g' | tr -d " "`
}

BASE_URL="https://oss.sonatype.org/content/groups/staging/net/kieker-monitoring/kieker"

# Download base maven-metadata.xml to find out the latest version
TMP_FILE_1=`mktemp`
METADATA="$BASE_URL/maven-metadata.xml"
curl -s $METADATA > $TMP_FILE_1
LATEST_VERSION_SNAPSHOT=`stripHtml $TMP_FILE_1 "latest"`

# Find out the name of the latest nightly build aspectj JAR file
TMP_FILE_2=`mktemp`
SUB_METADATA="$BASE_URL/$LATEST_VERSION_SNAPSHOT/maven-metadata.xml"
curl -s $SUB_METADATA > $TMP_FILE_2
LATEST_VERSION=`stripHtml $TMP_FILE_2 "version" | cut -d "-" -f 1`
TIMESTAMP=`stripHtml $TMP_FILE_2 "timestamp"`
BUILD_NUMBER=`stripHtml $TMP_FILE_2 "buildNumber"`

FILE_NAME="kieker-$LATEST_VERSION-$TIMESTAMP-$BUILD_NUMBER-aspectj.jar"

# Housekeeping
rm $TMP_FILE_1
rm $TMP_FILE_2

if [ -f Dockerfile ]; then
  sed -i "s%KIEKER_VERSION .*%KIEKER_VERSION $LATEST_VERSION-$TIMESTAMP-$BUILD_NUMBER%g" Dockerfile
  sed -i "s%KIEKER_AGENT_BASE_URL .*%KIEKER_AGENT_BASE_URL \"$BASE_URL/$LATEST_VERSION_SNAPSHOT\"%g" Dockerfile
fi

