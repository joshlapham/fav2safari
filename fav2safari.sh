#!/bin/bash

###
#
# fav2safari
# Converts Internet Explorer Favorites bookmarks from .url files to a .htm file that can be imported into Safari.
#
# By Josh Lapham [josh@joshlapham.com]
#
# https://github.com/joshlapham/fav2safari
#
# License: Beerware
# 
###

## VARIABLES
# Path to tempfile for cutting and pasting URLs
TEMPFILE="/tmp/.bm.txt"
# Path to Desktop
DESKTOP_PATH="/Users/$(whoami)/Desktop"
# Path to Bookmarks.htm file that can be imported into Safari
OUTPUTFILE="$DESKTOP_PATH/Bookmarks.htm"
# Path to Favorites directory
FAV_PATH="$DESKTOP_PATH/Favorites"
# For handling whitespace in folder names
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

## FUNCTIONS
findIntialURLs() {
    # Search through .url files for URLs, format nicely and store in temp file.
    grep -w 'URL' *.url | awk -F ".url|:URL=" '{ print "<DT><A HREF=\""$3"\">"$1"</a>" }' >> $TEMPFILE
}

findURLsInDirectories() {
    # Get current directory name but not full path
    CURRENTDIR=${PWD##*/}
    echo "<DT><H3 FOLDED>"$CURRENTDIR"</H3>" >> $TEMPFILE
    echo "<DL><p>" >> $TEMPFILE
    # Search through .url files for URLs, format nicely and store in temp file.
    grep -w 'URL' *.url | awk -F ".url|:URL=" '{ print "<DT><A HREF=\""$3"\">"$1"</a>" }' >> $TEMPFILE
    echo "</DL><p>" >> $TEMPFILE
}

finalOutput() {
    # Strip all newlines from file
    sed -e :a -e '$!N;s/\n//;ta' $TEMPFILE > $OUTPUTFILE
    # Strip ^M DOS character from file
    tr -d "\015" < $OUTPUTFILE > $TEMPFILE
    # Start <DT> tags on newline
    sed -e 's/<DT>/\
    <DT>/g' $TEMPFILE > $OUTPUTFILE
    # Get rid of any double quotation marks next to each other
    sed -e 's/""/"/g' $OUTPUTFILE > $TEMPFILE
    # Start <DL><p> tags on newline
    sed -e 's/<DL><p>/\
    <DL><p>/g' $TEMPFILE > $OUTPUTFILE
    # Start </DL><p> tags on newline
    sed -e 's/<\/DL><p>/\
    <\/DL><p>/g' $OUTPUTFILE > $TEMPFILE
    ## TESTING - too many redirects. Change me!
    cat $TEMPFILE > $OUTPUTFILE
    # Echo final output file
    cat $OUTPUTFILE > $TEMPFILE 
    # Print exit message
    echo "Bookmarks import file written to $OUTPUTFILE"
    # Clean up tempfile
    rm -f $TEMPFILE
}

writeHeader() {
    echo "<!DOCTYPE NETSCAPE-Bookmark-file-1>" >> $TEMPFILE
    echo "<Title>Bookmarks</title>" >> $TEMPFILE
    echo "<H1>Bookmarks</H1>" >> $TEMPFILE
    echo "<DL>" >> $TEMPFILE
}

writeFooter() {
    echo "</DL>" >> $TEMPFILE
}

## MAIN
# Check if a Favorites path was given; if not then look for Favorites folder on Desktop. Exit if none of these
if [[ ! -d $FAV_PATH && ! $1 ]]; then
    echo "Favorites folder path not given or found on Desktop."
    exit 1
fi
    # Check if a path was given; if so then set Favorites path variable accordingly
    if [[ $1 ]]; then
        export FAV_PATH=$1
    fi
    # Call writeHeader function to write header to output file
    writeHeader
    # Change to Favorites folder
    cd $FAV_PATH
    # Convert .urls at root of Favorites folder
    findIntialURLs
    # Find directories in Favorites path
    for i in $(find $FAV_PATH -d 1 -type d); do
        # Change into directories and convert .urls
        ( cd "$i" && findURLsInDirectories )
    done
    # Call writeFooter function to write footer to output file
    writeFooter
    # Write the final output file
    finalOutput

# restore $IFS variable
# for handling whitespace in folder names
IFS=$SAVEIFS
